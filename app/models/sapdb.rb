class Sapdb < ActiveRecord::Base
  establish_connection :sapdb
  # connection.raw_connection.recv_timeout = 100
  # connection.raw_connection.send_timeout = 50
  self.table_name = :dual
  self.primary_key = :dummy

end
