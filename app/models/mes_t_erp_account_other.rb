class MesTErpAccountOther < ActiveRecord::Base
  attr_accessor :ws_bal_qty #decimal
  attr_accessor :ws_alloc_qty #decimal
  attr_accessor :ws_locations #array
  attr_accessor :ws_movements #array

  self.table_name = :t_erp_account_other
  self.primary_key = :id
  establish_connection :leimes

  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.posting
    mat_lot_refs = []
    mes_t_erp_accounts = MesTErpAccountOther
                             .where(status: '10').where("quantity > 0")
                             .order(id: :asc)
    mes_t_erp_accounts.each do |row|
      MesTErpAccountOther.connection.execute("update t_erp_account_other set updated_time = sysdate where id=#{row.id}")
      row.ws_bal_qty = row.quantity - row.sap_posted_qty
      row.ws_alloc_qty = 0
      row.ws_locations = []
      row.ws_movements = []
      mat_lot_ref = "('#{row.plant}','#{row.material}','#{row.bacth}')"
      mat_lot_refs.append mat_lot_ref unless mat_lot_refs.include?(mat_lot_ref)
    end

    # get sap current location stock on hand
    mchbs = {}
    while mat_lot_refs.present?
      sql = "
          select matnr,werks,lgort,charg,clabs from sapsr3.mchb
            where mandt='168' and (werks,matnr,charg) in (#{mat_lot_refs.pop(500).join(',')}) and clabs > 0
            order by lgort desc
        "
      Sapdb.find_by_sql(sql).each do |row|
        key = "#{row.werks}.#{row.matnr}.#{row.charg}"
        mchbs[key] = [] unless mchbs.key?(key)
        mchbs[key].append(row)
      end
    end
    mes_t_erp_accounts.group_by(& :doc_id).each do |doc_id, accounts|
      accounts.each do |account|
        key = "#{account.plant}.#{account.material}.#{account.bacth}"
        if mchbs.key?(key)
          mchbs[key].each do |mchb|
            if mchb.clabs > 0
              ws_qty = account.ws_bal_qty > mchb.clabs ? mchb.clabs : account.ws_bal_qty
              account.ws_bal_qty -= ws_qty
              account.ws_alloc_qty += ws_qty
              mchb.clabs -= ws_qty
              if ws_qty > 0
                account.ws_movements.append({lgort: mchb.lgort, menge: ws_qty})
              end
            end
            break if account.ws_bal_qty == 0
          end #mchbs[key].each do |mchb|
        end
      end
      bapi_goodsmvt_create_261(accounts)
    end
  end

  def self.bapi_goodsmvt_create_261(mes_t_erp_accounts)
    perform_posting = false
    doc_id = ''
    order_id = ''
    mes_t_erp_accounts.each do |account|
      if account.ws_movements.present?
        perform_posting = true
        doc_id = account.doc_id
        order_id = account.order_id
        break
      end
    end
    return unless perform_posting

    begin
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_GOODSMVT_CREATE')
      function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '03')

      header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
      header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('PR_UNAME', 'LUM.LIN')
      header.setValue('REF_DOC_NO', order_id)
      header.setValue('HEADER_TXT', doc_id)

      lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
      line_id = 0
      mes_t_erp_accounts.each do |account|
        account.ws_movements.each do |hash|
          line_id = line_id + 10
          lines.appendRow()
          lines.setValue('LINE_ID', line_id)
          lines.setValue('MATERIAL', account.material)
          lines.setValue('PLANT', account.plant)
          lines.setValue('BATCH', account.bacth)
          lines.setValue('STGE_LOC', hash[:lgort])
          lines.setValue('MOVE_TYPE', '201')
          lines.setValue('COSTCENTER', account.o_code)
          lines.setValue('ENTRY_QNT', hash[:menge])
        end
      end

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)

      posting_success = true
      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each do |i|
        puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        if returnMessage.getString('TYPE').eql?('E')
          posting_success = false
        end
        returnMessage.nextRow
      end

      if posting_success
        mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
        mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')
        MesTErpAccountOther.transaction do
          line_id = 0
          mes_t_erp_accounts.each do |account|
            account.ws_movements.each do |hash|
              line_id += 10
              MesTErpAccountOtherIss.create(
                  uuid: UUID.new.generate(:compact),
                  teao_id: account.id,
                  mblnr: mblnr,
                  mjahr: mjahr,
                  zeile: line_id,
                  matnr: account.material,
                  charg: account.bacth,
                  menge: hash[:menge],
                  werks: account.plant,
                  lgort: hash[:lgort],
                  vtweg: PoReceipt.vtweg(account.plant)
              )
              account.sap_posted_qty += hash[:menge]
              account.status = 'X' if (account.sap_posted_qty) == account.quantity
              account.save
            end
          end
        end
      else #posting error
        mes_t_erp_accounts.each do |account|
          account.status = 'E'
          account.save
        end
      end
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)
    rescue Exception => exception
      Mail.defaults do
        delivery_method :smtp, address: '172.91.1.253', port: 25
      end
      message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

      Mail.deliver do
        from 'lum.cl@l-e-i.com'
        to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
        subject 'mes_t_erp_out_project bapi_goodsmvt_create_261'
        body message
      end

    end
  end


end