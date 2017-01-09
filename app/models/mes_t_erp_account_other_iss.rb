class MesTErpAccountOtherIss < ActiveRecord::Base
  establish_connection :leimes

  self.primary_key = :uuid
  self.table_name = :t_erp_account_other_iss


end