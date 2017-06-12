Rails.application.routes.draw do

  resources :saprfcs do
    get :dn_pack_qty, on: :collection
  end

  resources :rfc_msgs do
    get :msg, on: :collection
  end

  resources :stos do
    get :wait_dn_create, on: :collection
    get :wait_dn_issue, on: :collection
    get :wait_billing, on: :collection
    get :wait_goods_received, on: :collection
    get :rerun_rfc, on: :collection
  end

  resources :supplier_dns do
    get :display_dn_line, on: :collection
    get :create_po_receipt, on: :collection
    get :split_box, on: :collection
    post :confirm_split_box, on: :collection
  end

  resources :po_receipt_msgs
  resources :po_receipts do
    get :home, on: :collection
    get :domestic, on: :collection
    get :import_order, on: :collection
    get :combine_import_order, on: :collection
    get :direct_import, on: :collection
    get :direct_import_scan, on: :collection
    get :direct_import_allocate, on: :collection
    get :direct_import_unallocated, on: :collection
    get :direct_import_cfm_allocation, on: :collection
    get :barcode, on: :collection
    get :barcode_list, on: :collection
    get :unallocated, on: :collection
    get :allocate, on: :collection
    get :allocated_po, on: :collection
    get :dsp_rfc_msg, on: :collection
    get :repost, on: :collection
    get :deallocate_po, on: :collection
    post :cfm_allocation, on: :collection
    get :print_lot_label, on: :collection
    post :cfm_print_lot_label, on: :collection
    get :reprint_lot_label, on: :collection
    post :cfm_reprint_lot_label, on: :collection
    get :mseg_transfer_to_mes, on: :collection
    get :search_barcode, on: :collection
    get :transfer_to_mes, on: :member
  end

  resources :reports do
    get :open_sto_list, on: :collection
    get :check_dup_point, on: :collection
  end

  resources :user_ldaps do
    get :extra_info, on: :collection
    get :update_info, on: :collection
  end

  resources :printers
  devise_for :users
  #resources :users
  root to: 'visitors#index'

end
