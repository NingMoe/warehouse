class SupplierDnLine < ActiveRecord::Base
  self.primary_key = :uuid

  belongs_to :supplier_dn

  def split_box(params)
    str_seq = (seq / 1000).truncate * 1000
    end_seq = str_seq + 999
    max_seq = SupplierDnLine.where(supplier_dn_id: supplier_dn_id).where("seq between #{str_seq} and #{end_seq}").maximum(:seq)
    own_not_updated = true
    SupplierDnLine.transaction do
      (1..6).each do |i|
        if params["#{i}_total_qty"].to_f > 0
          if own_not_updated
            self.qty_per_box = params["#{i}_qty_per_box"]
            self.total_box = params["#{i}_total_box"]
            self.total_qty = params["#{i}_total_qty"]
            self.save
            own_not_updated = false
          else
            max_seq += 1
            new_obj = self.dup
            new_obj.seq = max_seq
            new_obj.qty_per_box = params["#{i}_qty_per_box"]
            new_obj.total_box = params["#{i}_total_box"]
            new_obj.total_qty = params["#{i}_total_qty"]
            new_obj.save
          end
        end
      end
    end
  end

end
