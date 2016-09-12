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
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')
      #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

      function = repos.getFunction('BAPI_GOODSMVT_CREATE')
      function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '01')

      header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
      header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'));
      header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'));
      if dlv_note.invnr.present?
        header.setValue('BILL_OF_LADING', dlv_note.invnr)
      else
        header.setValue('BILL_OF_LADING', dlv_note.lifdn)
      end
      header.setValue('REF_DOC_NO', dlv_note.lifdn);
      header.setValue('PR_UNAME', 'LUM.LIN');
      header.setValue('HEADER_TXT', dlv_note.lifdn);

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
    end

  end
end