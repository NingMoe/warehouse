class User < ActiveRecord::Base
  self.table_name = 'user_ldap'
  self.primary_key = :email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :ldap_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable

  devise :ldap_authenticatable

  def to_s
    email
  end

  def self.search(mail)
    ldap = Net::LDAP.new :host => 'taipei.l-e-i.com', # your LDAP host name or IP goes here,
                         :port => '389', # your LDAP host port goes here,
                         :base => 'O=leader' # the base of your AD tree goes here
    ldap.bind

    ldap.search :filter     => Net::LDAP::Filter.eq('mail', "#{mail}*"),
                :attributes => ['mail']
  end

end
