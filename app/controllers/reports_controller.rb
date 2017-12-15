class ReportsController < ApplicationController

  def index

  end

  def open_sto_list
    rows = Report.open_sto_list(params[:lifnr], params[:bukrs])
    send_data Excel.resultset(rows).to_stream.read,
              filename: "#{controller_name}_#{action_name}.xlsx"
  end

  def check_dup_point
    @rows = []
    if params[:aufnrs].present?
      @rows = MesTErpMoPoint.check_dup_point(text_area_to_array(params[:aufnrs]))
    end
  end

  def send_stock_idle
    fl = params[:fl]
    email = current_user.email
    Thread.new do
      Report.stock_idle_report(fl,email)
    end
    flash[:notice] = '您的請求已經在處理中，完成后會自動把EXCEL檔案送到您的郵箱, 請不要重複提交'
    redirect_to home_po_receipts_url
  end

  def update_stock_idle
    datas = text_area_to_array(params[:datas])
    Thread.new do
      Report.update_stock_idle(datas, current_user.email)
    end
    flash[:notice] = '您的請求已經在處理中，完成后會自動把EXCEL檔案送到您的郵箱, 請不要重複提交'
    redirect_to home_po_receipts_url
  end

end
