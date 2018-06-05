json.array!(@query_leis) do |row|
  json.extract! row, :id, :barcode, :cartonnumber
  json.url row_url(row, format: :json)
end
