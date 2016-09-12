class Excel
  
  def self.resultset(rows)
    Axlsx::Package.new do |excel|
      excel.workbook do |wb|
        wb.add_worksheet(name:'report') do |sheet|
          sheet.add_row rows.first.attribute_names
          rows.each do |row|
            values = []
            types = []
            rows.first.attribute_names.each do |field|
              values.append row[field]
              if row[field].class.to_s.eql?('String')
                types.append :string
              else
                types.append nil
              end
            end
            sheet.add_row values, types: types
          end
        end
      end
    end
  end
  
end