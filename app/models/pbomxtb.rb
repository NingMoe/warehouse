class Pbomxtb < ActiveRecord::Base
  self.table_name = :t_locationinfo
  self.primary_key = :locationinfo
  establish_connection :sapco

  def self.change_location_info
    rows = Pbomxtb.all
    rows.each do |row|
      numbers = %w[0 1 2 3 4 5 6 7 8 9]
      locationinfo = row.locationinfo
      new_location = []
      array = locationinfo.split(',')
      array.each do |element|
        if element.include?('-')
          buf = element.split('-')
          from = buf[0]
          to = buf[1]
          from_str = ''
          from_int = ''
          from.each_char do |char|
            if numbers.include?(char)
              from_int = "#{from_int}#{char}"
            else
              from_str = "#{from_str}#{char}"
            end
          end
          to_str = ''
          to_int = ''
          to.each_char do |char|
            if numbers.include?(char)
              to_int = "#{to_int}#{char}"
            else
              to_str = "#{to_str}#{char}"
            end
          end
          new_array = []
          if from_str.eql?(to_str)
            (from_int.to_i..to_int.to_i).each do |i|
              new_array.append("#{from_str}#{i}")
            end
            puts new_array.join(',')
            new_location.append(new_array.join(','))
          else
            new_location.append(element)
          end
        else
          new_location.append(element)
        end
      end
      row.locationinfo_new =  "#{new_location.join(',')},"
      row.save
    end
  end
end