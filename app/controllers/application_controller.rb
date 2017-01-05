class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from 'Java::JavaSql::SQLTimeoutException', with: :handle_timeout

  def handle_timeout(exception)
    redirect_to root_url(time_out: exception)
  end

  def text_area_to_array(text_area)
    array = Array.new
    buf = text_area.split("\n")
    buf.each do |s|
      array << s.strip.gsub("\r","")
    end
    array
  end

end
