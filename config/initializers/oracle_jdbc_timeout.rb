module ActiveRecord
  module ConnectionAdapters
    module OracleEnhanced
      module DatabaseStatements
        def exec_query(sql, name = 'SQL', binds = [])
          res = []
          begin
            Timeout::timeout(300) do
              res = exec_query_original(sql, name = 'SQL', binds = [])
            end
          rescue Timeout::Error
            Mail.defaults do
              delivery_method :smtp, address: '172.31.1.253', port: 25
            end
            Mail.deliver do
              from 'lum.cl@l-e-i.com'
              to 'lum.cl@l-e-i.com, felix.jiang@l-e-i.com'
              subject 'warehouse - oracle_jdbc_timeout.rb'
              body sql
            end
          end
          res
        end

        def exec_query_original(sql, name = 'SQL', binds = [])
          type_casted_binds = binds.map { |col, val|
            [col, type_cast(val, col)]
          }
          log(sql, name, type_casted_binds) do
            cursor = nil
            cached = false
            if without_prepared_statement?(binds)
              cursor = @connection.prepare(sql)
            else
              unless @statements.key? sql
                @statements[sql] = @connection.prepare(sql)
              end

              cursor = @statements[sql]

              type_casted_binds.each_with_index do |bind, i|
                col, val = bind
                cursor.bind_param(i + 1, val, col)
              end

              cached = true
            end

            cursor.exec

            if name == 'EXPLAIN' and sql =~ /^EXPLAIN/
              res = true
            else
              columns = cursor.get_col_names.map do |col_name|
                @connection.oracle_downcase(col_name)
              end
              rows = []
              fetch_options = {:get_lob_value => (name != 'Writable Large Object')}
              while row = cursor.fetch(fetch_options)
                rows << row
              end
              res = ActiveRecord::Result.new(columns, rows)
            end

            cursor.close unless cached
            res
          end
        end
      end
    end
  end
end
