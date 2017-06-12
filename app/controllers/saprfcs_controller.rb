class SaprfcsController < ApplicationController
  skip_before_filter :authenticate_user!

  def dn_pack_qty
    hash = {}
    hash = Saprfc.dn_pack_qty(params[:vbeln]) if params[:vbeln].present?
    render text: hash.to_json, layout: false
  end

end
