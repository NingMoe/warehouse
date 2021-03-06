class PoReceiptRfc
  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.sap_posting
    sql = "
      select a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')invnr
        from po_receipt a
          join po_receipt_line b on b.po_receipt_id = a.uuid
        where a.status='20' and a.rfc_sts <> 'E' and b.status = '20'
        group by a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')
    "
    dlv_notes = PoReceipt.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')
        #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

        function = repos.getFunction('BAPI_GOODSMVT_CREATE')
        function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '01')

        header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
        header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
        if dlv_note.invnr.present?
          header.setValue('BILL_OF_LADING', dlv_note.invnr)
        else
          header.setValue('BILL_OF_LADING', dlv_note.lifdn)
        end
        header.setValue('REF_DOC_NO', dlv_note.lifdn)
        header.setValue('PR_UNAME', 'LUM.LIN')
        header.setValue('HEADER_TXT', dlv_note.lifdn)

        lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        sql = "
        select a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
               b.ebeln,b.ebelp,
               sum(b.alloc_qty) alloc_qty,b.meins,
               b.impnr,b.impim,b.invnr
          from po_receipt a
            join po_receipt_line b on b.po_receipt_id = a.uuid
          where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
            and a.werks=? and nvl(b.invnr,' ') = ?
          group by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
                   b.ebeln,b.ebelp,b.impnr,b.impim,b.invnr,b.meins
      "
        pos = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
        pos.each do |po|
          lines.appendRow()
          lines.setValue('MATERIAL', po.matnr)
          lines.setValue('PLANT', po.werks)
          #lines.setValue("STGE_LOC", m.get("LGORT"));
          #lines.setValue("MOVE_STLOC", m.get("NLOGRT"));
          lines.setValue('BATCH', po.charg)
          lines.setValue('MOVE_TYPE', '101')
          lines.setValue('MVT_IND', 'B')
          lines.setValue('ENTRY_QNT', po.alloc_qty)
          lines.setValue('ENTRY_UOM', po.meins)
          lines.setValue('PO_NUMBER', po.ebeln)
          lines.setValue('PO_ITEM', po.ebelp)
          lines.setValue('VENDRBATCH', po.date_code)
          lines.setValue('PROD_DATE', po.mfg_date)
          lines.setValue('VENDOR', po.lifnr)
          lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
        end
        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)
        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)

        posting_success = true
        returnMessage = function.getTableParameterList().getTable('RETURN')
        (1..returnMessage.getNumRows).each do |i|
          puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
          if returnMessage.getString('TYPE').eql?('E')
            posting_success = false
            rfc_msg = "ID: #{returnMessage.getString('ID')} NUMBER: #{returnMessage.getString('NUMBER')} MESSAGE: #{returnMessage.getString('MESSAGE')}"
            PoReceiptMsg.create(
                lifnr: dlv_note.lifnr, lifdn: dlv_note.lifdn, werks: dlv_note.werks, invnr: dlv_note.invnr,
                rfc_type: returnMessage.getString('TYPE'), rfc_msg: rfc_msg
            )
          end
          returnMessage.nextRow
        end
        sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid
            where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
              and a.werks=? and nvl(b.invnr,' ') = ?
        "
        ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])

        PoReceipt.transaction do
          if posting_success
            mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
            mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids)
                  .update_all(status: '30', mblnr: mblnr, mjahr: mjahr, rfc_at: Time.now, rfc_type: 'S')
              if PoReceiptLine.where(status: '20', po_receipt_id: po_receipt_id).count == 0
                po_receipt = PoReceipt.find po_receipt_id
                po_receipt.status = '30'
                po_receipt.save
              end
            end
          else
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
              po_receipt = PoReceipt.find po_receipt_id
              po_receipt.rfc_sts = 'E'
              po_receipt.save
            end
          end
        end
      rescue Exception => exception
        # sql = "
        #   select distinct b.uuid,b.po_receipt_id
        #     from po_receipt a
        #       join po_receipt_line b on b.po_receipt_id = a.uuid
        #     where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
        #       and a.werks=? and nvl(b.invnr,' ') = ?
        # "
        # ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
        # ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
        #   PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
        #   po_receipt = PoReceipt.find po_receipt_id
        #   po_receipt.rfc_sts = 'E'
        #   po_receipt.save
        # end

        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.lifnr}, #{dlv_note.lifdn}, #{dlv_note.werks}, #{dlv_note.invnr}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'po_receipt_rfc_sap'
          body message
        end

      end
    end

  end

  def self.sap_posting_manual
    sql = "
      select a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')invnr
        from po_receipt a
          join po_receipt_line b on b.po_receipt_id = a.uuid
        where a.status='20' and a.rfc_sts = 'E' and b.status = '20'
        group by a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')
    "
    dlv_notes = PoReceipt.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')
        #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

        function = repos.getFunction('BAPI_GOODSMVT_CREATE')
        function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '01')

        header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
        header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
        if dlv_note.invnr.present?
          header.setValue('BILL_OF_LADING', dlv_note.invnr)
        else
          header.setValue('BILL_OF_LADING', dlv_note.lifdn)
        end
        header.setValue('REF_DOC_NO', dlv_note.lifdn)
        header.setValue('PR_UNAME', 'LUM.LIN')
        header.setValue('HEADER_TXT', dlv_note.lifdn)

        lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        sql = "
        select a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
               b.ebeln,b.ebelp,
               sum(b.alloc_qty) alloc_qty,b.meins,
               b.impnr,b.impim,b.invnr
          from po_receipt a
            join po_receipt_line b on b.po_receipt_id = a.uuid
          where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
            and a.werks=? and nvl(b.invnr,' ') = ?
          group by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
                   b.ebeln,b.ebelp,b.impnr,b.impim,b.invnr,b.meins
      "
        pos = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
        pos.each do |po|
          lines.appendRow()
          lines.setValue('MATERIAL', po.matnr)
          lines.setValue('PLANT', po.werks)
          #lines.setValue("STGE_LOC", m.get("LGORT"));
          #lines.setValue("MOVE_STLOC", m.get("NLOGRT"));
          lines.setValue('BATCH', po.charg)
          lines.setValue('MOVE_TYPE', '101')
          lines.setValue('MVT_IND', 'B')
          lines.setValue('ENTRY_QNT', po.alloc_qty)
          lines.setValue('ENTRY_UOM', po.meins)
          lines.setValue('PO_NUMBER', po.ebeln)
          lines.setValue('PO_ITEM', po.ebelp)
          lines.setValue('VENDRBATCH', po.date_code)
          lines.setValue('PROD_DATE', po.mfg_date)
          lines.setValue('VENDOR', po.lifnr)
          lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
        end
        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)
        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)

        puts "####################"
        line_return = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        (1..line_return.getNumRows).each do |i|
          puts "#{i} #{line_return.getString("LINE_ID")}
               #{line_return.getString("MATERIAL")}
               #{line_return.getString("PARENT_ID")}
               "
          line_return.nextRow
        end
        puts "####################"

        posting_success = true
        returnMessage = function.getTableParameterList().getTable('RETURN')
        (1..returnMessage.getNumRows).each do |i|
          puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
          if returnMessage.getString('TYPE').eql?('E')
            posting_success = false
            rfc_msg = "ID: #{returnMessage.getString('ID')} NUMBER: #{returnMessage.getString('NUMBER')} MESSAGE: #{returnMessage.getString('MESSAGE')}
            #{returnMessage.getString('MESSAGE_V1')}
            #{returnMessage.getString('MESSAGE_V2')}
            #{returnMessage.getString('MESSAGE_V3')}
            #{returnMessage.getString('MESSAGE_V4')}
            #{returnMessage.getString('PARAMETER')}
            #{returnMessage.getString('ROW')}
            #{returnMessage.getString('FIELD')}
            #{returnMessage.getString('SYSTEM')}
            "
            PoReceiptMsg.create(
                lifnr: dlv_note.lifnr, lifdn: dlv_note.lifdn, werks: dlv_note.werks, invnr: dlv_note.invnr,
                rfc_type: returnMessage.getString('TYPE'), rfc_msg: rfc_msg
            )
          end
          returnMessage.nextRow
        end

        sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid
            where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
              and a.werks=? and nvl(b.invnr,' ') = ?
        "
        ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])

        PoReceipt.transaction do
          if posting_success
            mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
            mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids)
                  .update_all(status: '30', mblnr: mblnr, mjahr: mjahr, rfc_at: Time.now, rfc_type: 'S')
              if PoReceiptLine.where(status: '20', po_receipt_id: po_receipt_id).count == 0
                po_receipt = PoReceipt.find po_receipt_id
                po_receipt.status = '30'
                po_receipt.save
              end
            end
          else
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
              po_receipt = PoReceipt.find po_receipt_id
              po_receipt.rfc_sts = 'E'
              po_receipt.save
            end
          end
        end
      rescue Exception => exception
        # sql = "
        #   select distinct b.uuid,b.po_receipt_id
        #     from po_receipt a
        #       join po_receipt_line b on b.po_receipt_id = a.uuid
        #     where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
        #       and a.werks=? and nvl(b.invnr,' ') = ?
        # "
        # ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
        # ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
        #   PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
        #   po_receipt = PoReceipt.find po_receipt_id
        #   po_receipt.rfc_sts = 'E'
        #   po_receipt.save
        # end

        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.lifnr}, #{dlv_note.lifdn}, #{dlv_note.werks}, #{dlv_note.invnr}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'po_receipt_rfc_sap'
          body message
        end

      end
    end

  end

  def self.sap_posting_repost(mjahr, mblnr)
    sql = "
      select a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')invnr
        from po_receipt a
          join po_receipt_line b on b.po_receipt_id = a.uuid and b.mblnr=? and b.mjahr=?
        group by a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')
    "
    dlv_notes = PoReceipt.find_by_sql([sql, mblnr, mjahr])
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')
        #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

        function = repos.getFunction('BAPI_GOODSMVT_CREATE')
        function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '01')

        header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
        header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
        if dlv_note.invnr.present?
          header.setValue('BILL_OF_LADING', dlv_note.invnr)
        else
          header.setValue('BILL_OF_LADING', dlv_note.lifdn)
        end
        header.setValue('REF_DOC_NO', dlv_note.lifdn)
        header.setValue('PR_UNAME', 'LUM.LIN')
        header.setValue('HEADER_TXT', dlv_note.lifdn)

        lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        sql = "
        select a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
               b.ebeln,b.ebelp,
               sum(b.alloc_qty) alloc_qty,b.meins,
               b.impnr,b.impim,b.invnr
          from po_receipt a
             join po_receipt_line b on b.po_receipt_id = a.uuid and b.mblnr=? and b.mjahr=?
          group by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
                   b.ebeln,b.ebelp,b.impnr,b.impim,b.invnr,b.meins
      "
        pos = PoReceipt.find_by_sql([sql, mblnr, mjahr])
        pos.each do |po|
          puts po.matnr
          lines.appendRow()
          lines.setValue('MATERIAL', po.matnr)
          lines.setValue('PLANT', po.werks)
          #lines.setValue("STGE_LOC", m.get("LGORT"));
          #lines.setValue("MOVE_STLOC", m.get("NLOGRT"));
          lines.setValue('BATCH', po.charg)
          lines.setValue('MOVE_TYPE', '101')
          lines.setValue('MVT_IND', 'B')
          lines.setValue('ENTRY_QNT', po.alloc_qty)
          lines.setValue('ENTRY_UOM', po.meins)
          lines.setValue('PO_NUMBER', po.ebeln)
          lines.setValue('PO_ITEM', po.ebelp)
          lines.setValue('VENDRBATCH', po.date_code)
          lines.setValue('PROD_DATE', po.mfg_date)
          lines.setValue('VENDOR', po.lifnr)
          lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
        end
        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)

        posting_success = true
        returnMessage = function.getTableParameterList().getTable('RETURN')
        (1..returnMessage.getNumRows).each do |i|
          puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
          if returnMessage.getString('TYPE').eql?('E')
            posting_success = false
            rfc_msg = "ID: #{returnMessage.getString('ID')} NUMBER: #{returnMessage.getString('NUMBER')} MESSAGE: #{returnMessage.getString('MESSAGE')}"
            PoReceiptMsg.create(
                lifnr: dlv_note.lifnr, lifdn: dlv_note.lifdn, werks: dlv_note.werks, invnr: dlv_note.invnr,
                rfc_type: returnMessage.getString('TYPE'), rfc_msg: rfc_msg
            )
          end
          returnMessage.nextRow
        end
        sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid and b.mblnr=? and b.mjahr=?
        "
        ids = PoReceipt.find_by_sql([sql, mblnr, mjahr])

        PoReceipt.transaction do
          if posting_success
            mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
            mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids)
                  .update_all(status: '30', mblnr: mblnr, mjahr: mjahr, rfc_at: Time.now, rfc_type: 'S')
              if PoReceiptLine.where(status: '20', po_receipt_id: po_receipt_id).count == 0
                po_receipt = PoReceipt.find po_receipt_id
                po_receipt.status = '30'
                po_receipt.save
              end
            end
          else
            ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
              PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
              po_receipt = PoReceipt.find po_receipt_id
              po_receipt.rfc_sts = 'E'
              po_receipt.save
            end
          end
        end
        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)
      rescue Exception => exception
        # sql = "
        #   select distinct b.uuid,b.po_receipt_id
        #     from po_receipt a
        #       join po_receipt_line b on b.po_receipt_id = a.uuid
        #     where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
        #       and a.werks=? and nvl(b.invnr,' ') = ?
        # "
        # ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
        # ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
        #   PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
        #   po_receipt = PoReceipt.find po_receipt_id
        #   po_receipt.rfc_sts = 'E'
        #   po_receipt.save
        # end

        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.lifnr}, #{dlv_note.lifdn}, #{dlv_note.werks}, #{dlv_note.invnr}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'po_receipt_rfc_sap'
          body message
        end

      end
    end

  end

  def self.combine_lot_ref
    sql = "
      select id rid,werks,matnr,charg,stkqty,lgort,licha,lifnr,frbnr,umcha
         from ws_mchb where charg <> umcha and elikz=' '
        order by werks,matnr,budat,lifnr,licha,frbnr
    "
    rows = Tmplumdb.find_by_sql(sql)
    rows.each do |row|
      puts "ID: #{row.rid}"
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')
        #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

        function = repos.getFunction('BAPI_GOODSMVT_CREATE')
        function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '04')

        header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
        header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('PR_UNAME', 'LUM.LIN')
        header.setValue('HEADER_TXT', 'COMBINE LOT')

        lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        lines.appendRow()
        lines.setValue('MATERIAL', row.matnr)
        lines.setValue('PLANT', row.werks)
        lines.setValue('STGE_LOC', row.lgort)
        lines.setValue('BATCH', row.charg)
        lines.setValue('MOVE_BATCH', row.umcha)
        lines.setValue('MOVE_TYPE', '311')
        #lines.setValue('MVT_IND', 'B')
        lines.setValue('ENTRY_QNT', row.stkqty)
        #lines.setValue('ENTRY_UOM', po.meins)
        #lines.setValue('PO_NUMBER', po.ebeln)
        #lines.setValue('PO_ITEM', po.ebelp)
        #lines.setValue('VENDRBATCH', po.date_code)
        #lines.setValue('PROD_DATE', po.mfg_date)
        #lines.setValue('VENDOR', po.lifnr)
        #lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
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
          sql = "update ws_mchb set elikz='#{mblnr}' where id='#{row.rid}'"
          Tmplumdb.connection.execute(sql)
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
          subject 'combine_lot_ref'
          body message
        end
      end
    end
  end

  def self.change_location
    sql = "
      select * from t001 where mblnr is null
    "
    rows = Tmplumdb.find_by_sql(sql)
    rows.each do |row|
      puts "ID: #{row.rid}"
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')
        #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

        function = repos.getFunction('BAPI_GOODSMVT_CREATE')
        function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '04')

        header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
        header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
        header.setValue('PR_UNAME', 'LUM.LIN')
        header.setValue('HEADER_TXT', 'INNO')

        lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
        lines.appendRow()
        lines.setValue('MATERIAL', row.matnr)
        lines.setValue('PLANT', row.werks)
        lines.setValue('STGE_LOC', row.lgort)
        lines.setValue('MOVE_STLOC', 'INNO')
        lines.setValue('BATCH', row.charg)
        lines.setValue('MOVE_BATCH', row.charg)
        lines.setValue('MOVE_TYPE', '311')
        #lines.setValue('MVT_IND', 'B')
        lines.setValue('ENTRY_QNT', row.issqty)
        #lines.setValue('ENTRY_UOM', po.meins)
        #lines.setValue('PO_NUMBER', po.ebeln)
        #lines.setValue('PO_ITEM', po.ebelp)
        #lines.setValue('VENDRBATCH', po.date_code)
        #lines.setValue('PROD_DATE', po.mfg_date)
        #lines.setValue('VENDOR', po.lifnr)
        #lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
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
          sql = "update t001 set mblnr='#{mblnr}' where rid='#{row.rid}'"
          Tmplumdb.connection.execute(sql)
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
          subject 'combine_lot_ref'
          body message
        end
      end
    end
  end
end