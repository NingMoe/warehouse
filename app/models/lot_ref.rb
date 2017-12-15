class LotRef < ActiveRecord::Base
  self.primary_key = :uuid

  def self.get_lot(matnr, lifnr, date_code, entry_date)
    (0..10).each do |i|
      @charg = find_lot(matnr, lifnr, date_code, entry_date)
      break if @charg.present?
    end
    @charg
  end

  def self.find_lot(matnr, lifnr, date_code, entry_date)
    Date.parse(entry_date) rescue entry_date = Date.today.strftime('%Y%m%d')

    lot_ref = LotRef
                  .where(matnr: matnr)
                  .where(lifnr: lifnr)
                  .where(date_code: date_code)
                  .where(entry_date: entry_date)
    #找到批次號
    return lot_ref.first.charg if lot_ref.present?

    #創建新的批次號
    last_charg = LotRef.where("charg like '#{entry_date[2..5]}%'").where("charg > '#{entry_date[2..5]}2'").maximum(:charg)

    charg = last_charg.nil? ? "#{entry_date[2..5]}200001" : (last_charg.to_i + 1).to_s

    lot_ref = LotRef.create(charg: charg, entry_date: entry_date, matnr: matnr, lifnr: lifnr, date_code: date_code)

    return lot_ref.present? ? lot_ref.charg : nil
  end

end
