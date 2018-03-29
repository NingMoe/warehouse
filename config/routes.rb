Rails.application.routes.draw do

  resources :mes_phicomms do
    get :check_sn_view, on: :collection
    post :check_sn_post, on: :collection
    get :print_mac_addr_view, on: :collection
    post :print_mac_addr_post, on: :collection
    get :print_sn_view, on: :collection
    post :print_sn_post, on: :collection
    get :print_sn1_view, on: :collection
    post :print_sn1_post, on: :collection
    get :print_sn2_view, on: :collection
    post :print_sn2_post, on: :collection
    get :print_color_box_label_view, on: :collection
    post :print_color_box_label_post, on: :collection
    get :print_nameplate_box_label_view, on: :collection
    post :print_nameplate_box_label_post, on: :collection
    get :print_outside_box_label_view, on: :collection
    get :print_outside_box_label_v_s, on: :collection
    post :print_outside_box_label_post, on: :collection
    get :update_kcode_view, on: :collection
    post :update_kcode_post, on: :collection
    post :update_printer, on: :collection
    post :get_product_info, on: :collection
    post :update_program_setting, on: :collection
    get :query_cartonnumber_view, on: :collection
    post :query_cartonnumber_post, on: :collection
    get :check_kcode_view, on: :collection
    post :check_kcode_post, on: :collection
    get :export_to_excel_view, on: :collection
    post :export_to_excel_post, on: :collection
    post :export_to_excel_download, on: :collection
    get :sn_check_sn_view, on: :collection
    post :sn_check_sn_post, on: :collection
    get :change_station_view, on: :collection
    post :change_station_post, on: :collection
    get :update_pallet_label_view, on: :collection
    post :update_pallet_label_post, on: :collection
    get :query_phicomm_view, on: :collection
    post :query_phicomm_post, on: :collection
    get :barcode_link_dn_view, on: :collection
    post :barcode_link_dn_post, on: :collection
    post :verify_dn_no_post, on: :collection
  end

  resources :mes do
    get :display_stock_area_info, on: :collection
    post :update_stock_area_info, on: :collection
    get :create_new_barcode_by_lot_view, on: :collection
    post :create_new_barcode_by_lot_post, on: :collection
    get :sn_enquiry_by_lot_view, on: :collection
    post :sn_enquiry_by_lot_post, on: :collection
  end

  resources :saprfcs do
    get :dn_pack_qty, on: :collection
    get :get_read_text, on: :collection
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
    post :received_excess_post, on: :collection
  end

  resources :reports do
    get :open_sto_list, on: :collection
    get :check_dup_point, on: :collection
    get :send_stock_idle, on: :collection
    post :update_stock_idle, on: :collection
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
