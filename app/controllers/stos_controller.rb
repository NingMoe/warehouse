class StosController < ApplicationController

  def index
  end

  def new
    if params[:sbm]
      if params[:impnr].present?
        pos = Sto.create_by_impnr(params[:impnr], params[:invnr] || '')
        pos.each do |po|
          Sto.create(
              vtweg: PoReceipt.vtweg(po.reswk), ebeln: po.ebeln, ebelp: po.ebelp,
              matnr: po.matnr, werks_from: po.reswk, werks_to: po.werks,
              menge: po.menge, meins: po.meins, lifnr: po.lifnr,
              impnr: po.impnr, impim: po.impim,
              status: '10WaitDnCreate',
              remote_ip: request.remote_ip, creator: current_user.email, updater: current_user.email
          )
        end
        redirect_to wait_dn_create_stos_url if pos.present?
      elsif params[:ebeln].present?
        @open_stos = Sto.open_sto_find_by_po(params[:ebeln], params[:ebelp], params[:werks])
      elsif params[:matnr].present?
        @open_stos = Sto.open_sto_find_by_material(params[:matnr], params[:werks])
      else
        @open_stos = []
      end
    end
  end

  def create
    po_ids = []
    params.keys.select { |b| b[0..2] == 'qty' }.each do |po_id|
      po_ids.append po_id.split('_')[1] if params[po_id].present? and params[po_id].to_f > 0
    end
    if po_ids.present?
      Sto.get_sap_po(po_ids).each do |po|
        Sto.create(
            vtweg: PoReceipt.vtweg(po.reswk), ebeln: po.ebeln, ebelp: po.ebelp,
            matnr: po.matnr, werks_from: po.reswk, werks_to: po.werks,
            menge: params["qty_#{po.ebeln}.#{po.ebelp}"], meins: po.meins, lifnr: po.lifnr,
            status: '10WaitDnCreate',
            remote_ip: request.remote_ip, creator: current_user.email, updater: current_user.email
        )
      end
    end
    redirect_to new_sto_url
  end

  def destroy
    @sto = Sto.find(params[:id])
    status = @sto.status
    vtweg = @sto.vtweg
    @sto.destroy
    if status.eql?('10WaitDnCreate')
      redirect_to wait_dn_create_stos_url(vtweg: vtweg)
    end
  end

  def rerun_rfc
    sto = Sto.find_by(rfc_batch_id: params[:rfc_batch_id])
    Sto.where(rfc_batch_id: params[:rfc_batch_id]).update_all(rfc_msg_type: '')
    RfcMsg.delete_all(rfc_batch_id: params[:rfc_batch_id])
    if sto.status.eql?('10WaitDnCreate')
      redirect_to wait_dn_create_stos_url(vtweg: sto.vtweg)
    end
  end

  def wait_dn_create
    @stos = Sto.where(status: '10WaitDnCreate', vtweg: params[:vtweg] || current_user.vtweg)
  end

  def wait_dn_issue
    @stos = Sto.where(status: '20WaitDNIssue', vtweg: params[:vtweg] || current_user.vtweg)
  end

  def wait_billing
    @stos = Sto.where(status: '30WaitBilling', vtweg: params[:vtweg] || current_user.vtweg)
  end

  def wait_goods_received
    @stos = Sto.where(status: '40WaitGoodsReceived', vtweg: params[:vtweg] || current_user.vtweg)
  end

end
