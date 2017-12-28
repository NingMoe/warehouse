class MesController < ApplicationController

  def display_stock_area_info
    @rows = []
    if params[:sad_doc_number].present? or params[:sad_item_code].present? or
        params[:sad_tatch_num].present? or params[:sad_area_s].present?
      sql = "
        select /*+ index(a T_WMS_STOCK_AREA_DETAIL_IDX3) */
               a.sad_id,a.sad_doc_number,a.sad_item_code,a.sad_tatch_num,a.sad_area_sa,a.sad_area_s,
               a.sad_stock_num,a.sad_create_date,a.sad_sn
          from t_wms_stock_area_detail a
          where a.sap_status=0 and a.sad_status='1'
            and a.sad_doc_number like '%#{params[:sad_doc_number]}%'
            and a.sad_item_code like '%#{params[:sad_item_code]}%'
            and a.sad_tatch_num like '%#{params[:sad_tatch_num]}%'
            and a.sad_area_s like '%#{params[:sad_area_s]}%'
          order by a.sad_create_date
      "
      @rows = Leimes.find_by_sql(sql)
    end
  end

  def update_stock_area_info
    if params[:sad_ids].present?
      sad_2 = "删除 #{current_user.email} #{Time.now.strftime('%Y%m%d %H:%M')}"
      params[:sad_ids].each do |row|
        sql = "update t_wms_stock_area_detail set sad_status='4', sad_2='#{sad_2}' where sad_id=#{row}"
        Leimes.connection.execute sql
      end
    end
    redirect_to display_stock_area_info_mes_url, notice: '刪除完成'
  end

  def create_new_barcode_by_lot_view

  end

  def create_new_barcode_by_lot_post
    if params[:datas].present?
      i = 0
      text_area_to_array(params[:datas]).each do |record|
        fields = record.split("\t")
        werks = fields[0]
        matnr = fields[1]
        charg = fields[2]
        menge = fields[3]
        sql = "
          select a.mblnr,a.mjahr,a.zeile,a.matnr,a.werks,a.charg,a.lifnr,
               a.menge,a.ebeln,a.ebelp,b.hsdat,b.licha,c.budat,c.frbnr,
               c.xblnr
            from tmplum.mch1x d
            join sapsr3.mseg a on a.mandt='168' and a.mblnr=d.mblnr and a.mjahr=d.mjahr and a.zeile=d.zeile
            join sapsr3.mkpf c on c.mandt='168' and c.mblnr=a.mblnr and c.mjahr=a.mjahr
            left join sapsr3.mch1 b on b.mandt='168' and b.matnr=a.matnr and b.charg=a.charg
          where d.matnr=? and d.charg=?
        "
        po_receipts = Sapdb.find_by_sql([sql, matnr, charg])
        po_receipts.each do |po_receipt|
          i = i + 1
          MesTErpPoItem.create!(
              po_number: po_receipt.ebeln,
              item_line: po_receipt.ebelp,
              item_code: po_receipt.matnr,
              item_num: 0,
              item_lot: po_receipt.charg,
              item_sn: "MB#{po_receipt.mjahr}.#{po_receipt.mblnr}.#{po_receipt.zeile}.#{po_receipt.charg}.#{Time.now.strftime('%y%m%d%H%M')}#{i}",
              item_sn_qty: menge,
              receive_type: '0',
              supplier_code: po_receipt.lifnr,
              supplier_lot: po_receipt.licha,
              supplier_date: po_receipt.hsdat,
              plant: werks,
              has_label: 0,
              supplier_dn: po_receipt.xblnr
          )
        end
      end
    end
    redirect_to  create_new_barcode_by_lot_view_mes_url
  end

  def sn_enquiry_by_lot_view

  end

  def sn_enquiry_by_lot_post
    lots = []
    if params[:datas].present?
      text_area_to_array(params[:datas]).each do |record|
        fields = record.split("\t")
        werks = fields[0]
        matnr = fields[1]
        charg = fields[2]
        lots.append("('#{matnr}','#{charg}','#{werks}')")
      end
      sql = "
        select b.sn_id, a.wrds_item_code,a.wrds_batch_sn,a.wrds_recive_num,a.count_time,c.wr_store_code
          from t_wms_receive_detail_sub a
            join t_wms_receive c on c.wr_doc_num = a.wrds_order_no
            left join t_sn_id b on b.item_sn=a.wrds_item_sn
          where a.wrds_instock_man is null and (a.wrds_item_code,a.wrds_batch_sn,c.wr_store_code) in (#{lots.join(',')})
      "
      @rows = MesTErpPoItem.find_by_sql(sql)
    end
  end

end
