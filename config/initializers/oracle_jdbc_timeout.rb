module ActiveRecord
  module ConnectionAdapters
    class OracleEnhancedJDBCConnection < OracleEnhancedConnection
      class Cursor
        def exec
          #setQueryTimeout = 120 seconds
          @raw_statement.setQueryTimeout(120)
          @raw_result_set = @raw_statement.executeQuery
          true
        end
      end
    end
  end
end
