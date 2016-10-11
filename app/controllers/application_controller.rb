class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Timeout::Error, with: :handle_timeout

  def handle_timeout
    render :text => exception, :status => 500
  end

end
