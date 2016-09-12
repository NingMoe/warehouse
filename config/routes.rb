Rails.application.routes.draw do


  resources :po_receipt_msgs
  resources :po_receipts do
    get :home, on: :collection
    get :domestic, on: :collection
    get :direct_import, on: :collection
    get :direct_import_scan, on: :collection
    get :direct_import_allocate, on: :collection
    get :direct_import_unallocated, on: :collection
    get :barcode, on: :collection
    get :barcode_list, on: :collection
    get :unallocated, on: :collection
    get :allocate, on: :collection
    get :allocated_po, on: :collection
    get :dsp_rfc_msg, on: :collection
    get :repost, on: :collection
    get :deallocate_po, on: :collection
    post :cfm_allocation, on: :collection
  end

  resources :reports do
    get :open_sto_list, on: :collection
  end

  devise_for :users
  #resources :users
  root to: 'visitors#index'

end
