class ReportsController < ApplicationController

  def index

  end

  def open_sto_list
    rows = Report.open_sto_list(params[:lifnr], params[:bukrs])
    send_data Excel.resultset(rows).to_stream.read,
              filename: "#{controller_name}_#{action_name}.xlsx"
  end


end
