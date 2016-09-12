class PoReceiptsController < ApplicationController
  before_action :set_po_receipt, only: [:show, :edit, :update, :destroy]

  # GET /po_receipts
  # GET /po_receipts.json
  def home

  end

  def index
    @po_receipts = PoReceipt.all
  end

  # GET /po_receipts/1
  # GET /po_receipts/1.json
  def show
  end

  # GET /po_receipts/new
  def new
    @po_receipt = PoReceipt.new
  end

  # GET /po_receipts/1/edit
  def edit
  end

  # POST /po_receipts
  # POST /po_receipts.json
  def create
    @po_receipt = PoReceipt.new(po_receipt_params)

    respond_to do |format|
      if @po_receipt.save
        format.html { redirect_to @po_receipt, notice: 'Po receipt was successfully created.' }
        format.json { render :show, status: :created, location: @po_receipt }
      else
        format.html { render :new }
        format.json { render json: @po_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /po_receipts/1
  # PATCH/PUT /po_receipts/1.json
  def update
    respond_to do |format|
      if @po_receipt.update(po_receipt_params)
        format.html { redirect_to @po_receipt, notice: 'Po receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @po_receipt }
      else
        format.html { render :edit }
        format.json { render json: @po_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /po_receipts/1
  # DELETE /po_receipts/1.json
  def destroy
    @po_receipt.destroy
    respond_to do |format|
      format.html { redirect_to po_receipts_url, notice: 'Po receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def direct_import
    current_month = Date.today.strftime('%y%m')
    last_month = (Date.today - 1.month).strftime('%y%m')
    if current_user.vtweg.present?
      if current_user.vtweg.eql?('TX')
        impnr = "(impnr between 'ITX#{last_month}' and 'ITX#{current_month}Z')"
      else
        impnr = "(impnr between 'DIM#{last_month}' and 'DIM#{current_month}Z')"
      end
    else
      impnr = "((impnr between 'ITX#{last_month}' and 'ITX#{current_month}Z') or (impnr between 'DIM#{last_month}' and 'DIM#{current_month}Z'))"
    end
    sql = "
      select dpseq,impnr,imdat,bukrs
        from sapsr3.ziebi001
        where mandt='168' and #{impnr}
          and loekz=' ' and imstu in ('2','3')
        order by dpseq desc,impnr
    "
    @ziebi001s = Sapdb.find_by_sql(sql)
  end

  def direct_import_scan
    if Ziebi002.find_by_bukrs_and_dpseq(params[:bukrs],params[:dpseq]).blank?
      Ziebi002.create_record_from_sap(params[:impnrs].split(','))
    end
  end

  def domestic

  end

  def barcode
    barcode = params[:barcode]

    if PoReceipt.barcode_present?(barcode)
      @error_msg = '條碼重複! Duplicate Barcode!'
    else
      contents = PoReceipt.barcode_content(barcode)
      @error_msg = contents if contents.class.to_s.eql?('String')
    end

    if @error_msg.blank? and params[:vtype].eql?('V1')
      @error_msg = Ziebi002.check_barcode(params[:bukrs], params[:dpseq], contents)
    end

    if @error_msg.blank?
      @po_receipt = PoReceipt.create(
          barcode: barcode,
          vtweg: PoReceipt.vtweg(contents[:werks]),
          lifnr: contents[:lifnr],
          lifdn: contents[:lifdn],
          matnr: contents[:matnr],
          werks: contents[:werks],
          pkg_no: contents[:pkg_no],
          date_code: contents[:date_code],
          mfg_date: contents[:mfg_date],
          menge: contents[:menge],
          balqty: contents[:menge],
          entry_date: Date.today.strftime("%Y%m%d"),
          status: '10',
          vtype: params[:vtype] || ' ',
          bukrs: params[:bukrs] || '',
          dpseq: params[:dpseq] || '',
          impnr: params[:impnrs] || '',
          charg: LotRef.get_lot(contents[:matnr], contents[:lifnr], contents[:date_code], Date.today.strftime("%Y%m%d")),
          remote_ip: request.remote_ip,
          creator: current_user.email,
          updater: current_user.email
      )
    end
  end

  def barcode_list
    @po_receipts = PoReceipt.select(:barcode, :pkg_no, :matnr, :date_code, :mfg_date, :menge)
                       .where(lifnr: params[:lifnr], lifdn: params[:lifdn])
                       .where("matnr like '%#{params[:matnr]}%'")
                       .order(:matnr, :pkg_no)

  end

  def unallocated
    sql = "
        select entry_date,lifnr,lifdn,werks,sum(balqty) menge, sum(pkg_no) pkg_no, vtype, impnr
          from po_receipt
          where status='10'
            and vtweg='#{params[:vtweg] || current_user.vtweg}'
            and lifnr like '%#{params[:lifnr]}%'
            and lifdn like '%#{params[:lifdn]}%'
            and entry_date like '%#{params[:entry_date]}%'
          group by entry_date,lifnr,lifdn,werks,vtype,impnr
          order by lifnr,lifdn,werks,vtype
      "
    @po_receipts = PoReceipt.find_by_sql(sql)
  end

  def allocate
    if params[:lifdn].blank? or params[:lifnr].blank? or params[:werks].blank?
      redirect_to unallocated_po_receipts_url, notice: '操作錯誤, Wrong Operation'
    else
      @mats, @pos = PoReceipt.allocate_po(params[:lifnr], params[:lifdn], params[:werks])
    end
  end

  def direct_import_unallocated
    sql = "
        select a.bukrs,a.impnr,a.dpseq,a.werks,sum(a.menge) menge,
               sum(a.alloc_qty) alloc_qty,sum(a.balqty) balqty
          from po_receipt a
        where a.status='10' and a.vtype='V1' and a.vtweg like '%#{current_user.vtweg}%'
        group by a.bukrs,a.impnr,a.dpseq,a.werks
    "
    @po_receipts = PoReceipt.find_by_sql(sql)
  end

  def direct_import_allocate
    sql = "
      with
        tmpa as (
          select a.matnr,a.lifnr,a.werks,sum(a.menge) menge
            from ziebi002 a
            where a.bukrs='#{params[:bukrs]}' and a.dpseq='#{params[:dpseq]}'
            group by a.matnr,a.lifnr,a.werks),
        tmpb as (
          select b.matnr,b.lifnr,b.werks,sum(b.menge) menge,
                 sum(b.alloc_qty) alloc_qty, sum(b.balqty) balqty
            from po_receipt b
            where b.bukrs='#{params[:bukrs]}' and b.dpseq='#{params[:dpseq]}'
            group by b.matnr,b.lifnr,b.werks)
        select a.matnr,a.lifnr,a.werks,a.menge,
               nvl(b.menge,0) scanqty, nvl(b.alloc_qty,0) alloc_qty, nvl(b.balqty,0) balqty
          from tmpa a
            left join tmpb b on b.matnr=a.matnr and b.lifnr=a.lifnr and b.werks=a.werks
        order by a.matnr
    "
    @rows = Ziebi002.find_by_sql(sql)
    @complete_scan = false
    @incomplete_scan = false
    @not_scan = false
    @allocated = false
    @rows.each do |row|
      @complete_scan = true if row.menge == row.balqty
      @incomplete_scan = true if row.menge != row.balqty and row.scanqty > 0
      @not_scan = true if row.scanqty == 0
      @allocated = true if row.menge == row.alloc_qty
      break if @complete_scan and @incomplete_scan and @allocated
    end
  end

  def direct_import_cfm_allocation
    if params[:bukrs].blank? or params[:impnrs].blank? or params[:dpseq].blank? or params[:user].blank?
      redirect_to direct_import_unallocated_po_receipts_path, notice: '操作錯誤, Wrong Operation'
    else
      PoReceipt.direct_import_cfm_allocation(params)
    end
  end

  def cfm_allocation
    if params[:lifdn].blank? or params[:lifnr].blank? or params[:werks].blank?
      redirect_to unallocated_po_receipts_url, notice: '操作錯誤, Wrong Operation'
    else
      PoReceipt.cfm_allocation(params)
      redirect_to unallocated_po_receipts_url
    end
  end

  def allocated_po
    sql = "
      select a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
             b.ebeln,b.ebelp,
             sum(b.alloc_qty) alloc_qty, b.meins,
             b.impnr,b.impim,b.invnr,b.rfc_type
        from po_receipt a
          join po_receipt_line b on b.po_receipt_id = a.uuid
        where a.status='20'
          and vtweg='#{params[:vtweg] || current_user.vtweg}'
          and lifnr like '%#{params[:lifnr]}%'
          and lifdn like '%#{params[:lifdn]}%'
        group by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
                 b.ebeln,b.ebelp,b.impnr,b.impim,b.invnr,b.rfc_type, b.meins
        order by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg
    "
    @po_receipts = PoReceipt.find_by_sql(sql)
  end

  def dsp_rfc_msg
    @msgs = PoReceiptMsg
                .where(lifnr: params[:lifnr], lifdn: params[:lifdn],
                       werks: params[:werks], invnr: params[:invnr])
  end

  def repost
    sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid
            where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
              and a.rfc_sts='E' and b.rfc_type='E'
              and a.werks=? and nvl(b.invnr,' ') = ?
        "
    ids = PoReceipt.find_by_sql([sql,params[:lifnr], params[:lifdn], params[:werks], params[:invnr]])
    ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
      PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: ' ')
      po_receipt = PoReceipt.find po_receipt_id
      po_receipt.rfc_sts = ' '
      po_receipt.save
    end
    redirect_to allocated_po_po_receipts_path
  end

  def deallocate_po
    sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid
            where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
              and a.rfc_sts='E' and b.rfc_type='E'
              and a.werks=? and nvl(b.invnr,' ') = ?
        "
    ids = PoReceipt.find_by_sql([sql,params[:lifnr], params[:lifdn], params[:werks], params[:invnr]])
    ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
      alloc_qty = PoReceiptLine.where(uuid: po_receipt_line_ids).sum(:alloc_qty)
      PoReceiptLine.delete_all(uuid: po_receipt_line_ids)
      po_receipt = PoReceipt.find po_receipt_id
      po_receipt.rfc_sts = ' '
      po_receipt.balqty += alloc_qty
      po_receipt.alloc_qty -= alloc_qty
      po_receipt.status = '10'
      po_receipt.save
    end
    redirect_to allocated_po_po_receipts_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_po_receipt
    @po_receipt = PoReceipt.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def po_receipt_params
    params.require(:po_receipt).permit(:uuid, :barcode, :vtweg, :lifnr, :lifdn, :matnr, :werks, :pkg_no, :date_code, :mfg_date, :menge, :alloc_qty, :balqty, :status, :vtype, :impnr, :charg, :remote_ip, :creator, :updater)
  end
end
