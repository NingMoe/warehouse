require 'test_helper'

class PoReceiptsControllerTest < ActionController::TestCase
  setup do
    @po_receipt = po_receipt(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:po_receipt)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create po_receipt" do
    assert_difference('PoReceipt.count') do
      post :create, po_receipt: { alloc_qty: @po_receipt.alloc_qty, balqty: @po_receipt.balqty, barcode: @po_receipt.barcode, charg: @po_receipt.charg, creator: @po_receipt.creator, date_code: @po_receipt.date_code, impnr: @po_receipt.impnr, lifdn: @po_receipt.lifdn, lifnr: @po_receipt.lifnr, matnr: @po_receipt.matnr, menge: @po_receipt.menge, mfg_date: @po_receipt.mfg_date, pkg_no: @po_receipt.pkg_no, remote_ip: @po_receipt.remote_ip, status: @po_receipt.status, updater: @po_receipt.updater, uuid: @po_receipt.uuid, vtweg: @po_receipt.vtweg, vtype: @po_receipt.vtype, werks: @po_receipt.werks }
    end

    assert_redirected_to po_receipt_path(assigns(:po_receipt))
  end

  test "should show po_receipt" do
    get :show, id: @po_receipt
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @po_receipt
    assert_response :success
  end

  test "should update po_receipt" do
    patch :update, id: @po_receipt, po_receipt: { alloc_qty: @po_receipt.alloc_qty, balqty: @po_receipt.balqty, barcode: @po_receipt.barcode, charg: @po_receipt.charg, creator: @po_receipt.creator, date_code: @po_receipt.date_code, impnr: @po_receipt.impnr, lifdn: @po_receipt.lifdn, lifnr: @po_receipt.lifnr, matnr: @po_receipt.matnr, menge: @po_receipt.menge, mfg_date: @po_receipt.mfg_date, pkg_no: @po_receipt.pkg_no, remote_ip: @po_receipt.remote_ip, status: @po_receipt.status, updater: @po_receipt.updater, uuid: @po_receipt.uuid, vtweg: @po_receipt.vtweg, vtype: @po_receipt.vtype, werks: @po_receipt.werks }
    assert_redirected_to po_receipt_path(assigns(:po_receipt))
  end

  test "should destroy po_receipt" do
    assert_difference('PoReceipt.count', -1) do
      delete :destroy, id: @po_receipt
    end

    assert_redirected_to po_receipts_path
  end
end
