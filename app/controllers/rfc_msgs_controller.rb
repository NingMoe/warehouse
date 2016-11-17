class RfcMsgsController < ApplicationController

  def msg
    @rfc_msgs = RfcMsg.where(rfc_batch_id: params[:rfc_batch_id]).order(:uuid)
  end


end