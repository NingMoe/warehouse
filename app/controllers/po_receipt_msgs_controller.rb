class PoReceiptMsgsController < ApplicationController
  before_action :set_po_receipt_msg, only: [:show, :edit, :update, :destroy]

  # GET /po_receipt_msgs
  # GET /po_receipt_msgs.json
  def index
    @po_receipt_msgs = PoReceiptMsg.all
  end

  # GET /po_receipt_msgs/1
  # GET /po_receipt_msgs/1.json
  def show
  end

  # GET /po_receipt_msgs/new
  def new
    @po_receipt_msg = PoReceiptMsg.new
  end

  # GET /po_receipt_msgs/1/edit
  def edit
  end

  # POST /po_receipt_msgs
  # POST /po_receipt_msgs.json
  def create
    @po_receipt_msg = PoReceiptMsg.new(po_receipt_msg_params)

    respond_to do |format|
      if @po_receipt_msg.save
        format.html { redirect_to @po_receipt_msg, notice: 'Po receipt msg was successfully created.' }
        format.json { render :show, status: :created, location: @po_receipt_msg }
      else
        format.html { render :new }
        format.json { render json: @po_receipt_msg.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /po_receipt_msgs/1
  # PATCH/PUT /po_receipt_msgs/1.json
  def update
    respond_to do |format|
      if @po_receipt_msg.update(po_receipt_msg_params)
        format.html { redirect_to @po_receipt_msg, notice: 'Po receipt msg was successfully updated.' }
        format.json { render :show, status: :ok, location: @po_receipt_msg }
      else
        format.html { render :edit }
        format.json { render json: @po_receipt_msg.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /po_receipt_msgs/1
  # DELETE /po_receipt_msgs/1.json
  def destroy
    @po_receipt_msg.destroy
    respond_to do |format|
      format.html { redirect_to po_receipt_msgs_url, notice: 'Po receipt msg was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_po_receipt_msg
      @po_receipt_msg = PoReceiptMsg.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def po_receipt_msg_params
      params.require(:po_receipt_msg).permit(:uuid, :lifnr, :lifdn, :werks, :invnr, :rfc_type, :rfc_msg)
    end
end
