class MesTErpOutProjectIss < ActiveRecord::Base
  establish_connection :leimes

  self.primary_key = :uuid
  self.table_name = :t_erp_out_project_iss


end