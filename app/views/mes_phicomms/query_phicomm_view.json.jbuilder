json.array!(@query_phicomms) do |row|
  json.extract! row, :id, :sn, :kcode
  json.url row_url(row, format: :json)
end
