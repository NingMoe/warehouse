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

  end

end
