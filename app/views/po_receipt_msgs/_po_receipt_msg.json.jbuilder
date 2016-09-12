json.extract! po_receipt_msg, :id, :uuid, :lifnr, :lifdn, :werks, :invnr, :rfc_type, :rfc_msg, :created_at, :updated_at
json.url po_receipt_msg_url(po_receipt_msg, format: :json)