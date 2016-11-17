class SupplierDnsController < ApplicationController
  before_action :set_supplier_dn, only: [:show, :edit, :update, :destroy]

  # GET /supplier_dns
  # GET /supplier_dns.json
  def index
    @supplier_dns = SupplierDn.all
  end

  # GET /supplier_dns/1
  # GET /supplier_dns/1.json
  def show
  end

  # GET /supplier_dns/new
  def new
    @supplier_dn = SupplierDn.new
  end

  # GET /supplier_dns/1/edit
  def edit
  end

  # POST /supplier_dns
  # POST /supplier_dns.json
  def create
    @supplier_dn = SupplierDn.new(supplier_dn_params)

    respond_to do |format|
      if @supplier_dn.create_sto
        format.html { redirect_to new_supplier_dn_url, notice: 'Supplier dn was successfully created.' }
        format.json { render :show, status: :created, location: @supplier_dn }
      else
        format.html { render :new }
        format.json { render json: @supplier_dn.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_dns/1
  # PATCH/PUT /supplier_dns/1.json
  def update
    respond_to do |format|
      if @supplier_dn.update(supplier_dn_params)
        format.html { redirect_to @supplier_dn, notice: 'Supplier dn was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier_dn }
      else
        format.html { render :edit }
        format.json { render json: @supplier_dn.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_dns/1
  # DELETE /supplier_dns/1.json
  def destroy
    @supplier_dn.destroy
    respond_to do |format|
      format.html { redirect_to supplier_dns_url, notice: 'Supplier dn was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def display_dn_line
    @supplier_dn = SupplierDn.find_by(uuid: params[:uuid])
  end

  def create_po_receipt
    @supplier_dn = SupplierDn.find_by(uuid: params[:uuid])
    @supplier_dn.create_po_receipt
    redirect_to supplier_dns_url
  end

  def split_box
    @supplier_dn_line = SupplierDnLine.find_by(uuid: params[:uuid])
  end

  def confirm_split_box
    @supplier_dn_line = SupplierDnLine.find_by(uuid: params[:uuid])
    @supplier_dn_line.updater = current_user.email
    @supplier_dn_line.split_box(params)
    redirect_to display_dn_line_supplier_dns_url(uuid: @supplier_dn_line.supplier_dn_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_dn
      @supplier_dn = SupplierDn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_dn_params
      params.require(:supplier_dn).permit(:uuid, :vtweg, :werks, :lifnr, :lifdn, :vbeln, :status, :vtype, :impnr, :remote_ip, :creator, :updater)
    end
end
