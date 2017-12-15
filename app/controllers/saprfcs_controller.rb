class SaprfcsController < ApplicationController
  skip_before_filter :authenticate_user!

  def dn_pack_qty
    hash = {}
    hash = Saprfc.dn_pack_qty(params[:vbeln]) if params[:vbeln].present?
    render text: hash.to_json, layout: false
  end

  def get_read_text
    table = {}
    table = Saprfc.get_read_text(params[:text_lines_table_json]) if params[:text_lines_table_json].present?
    render text: table.to_json
  end

end
