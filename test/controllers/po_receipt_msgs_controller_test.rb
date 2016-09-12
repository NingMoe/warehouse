require 'test_helper'

class PoReceiptMsgsControllerTest < ActionController::TestCase
  setup do
    @po_receipt_msg = po_receipt_msg(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:po_receipt_msg)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create po_receipt_msg" do
    assert_difference('PoReceiptMsg.count') do
      post :create, po_receipt_msg: { invnr: @po_receipt_msg.invnr, lifdn: @po_receipt_msg.lifdn, lifnr: @po_receipt_msg.lifnr, rfc_msg: @po_receipt_msg.rfc_msg, rfc_type: @po_receipt_msg.rfc_type, uuid: @po_receipt_msg.uuid, werks: @po_receipt_msg.werks }
    end

    assert_redirected_to po_receipt_msg_path(assigns(:po_receipt_msg))
  end

  test "should show po_receipt_msg" do
    get :show, id: @po_receipt_msg
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @po_receipt_msg
    assert_response :success
  end

  test "should update po_receipt_msg" do
    patch :update, id: @po_receipt_msg, po_receipt_msg: { invnr: @po_receipt_msg.invnr, lifdn: @po_receipt_msg.lifdn, lifnr: @po_receipt_msg.lifnr, rfc_msg: @po_receipt_msg.rfc_msg, rfc_type: @po_receipt_msg.rfc_type, uuid: @po_receipt_msg.uuid, werks: @po_receipt_msg.werks }
    assert_redirected_to po_receipt_msg_path(assigns(:po_receipt_msg))
  end

  test "should destroy po_receipt_msg" do
    assert_difference('PoReceiptMsg.count', -1) do
      delete :destroy, id: @po_receipt_msg
    end

    assert_redirected_to po_receipt_msgs_path
  end
end
