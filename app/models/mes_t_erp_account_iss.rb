class MesTErpAccountIss < ActiveRecord::Base
  establish_connection :leimes

  self.primary_key = :uuid
  self.table_name = :t_erp_account_iss


end