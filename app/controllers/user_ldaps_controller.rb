class UserLdapsController < ApplicationController

  def extra_info
    @user = User.find_by_email(current_user.email)
  end

  def update_info
    user = User.find_by_email(params[:email])
    user.name = params[:name]
    user.vtweg = params[:vtweg]
    user.lot_label_printer_id = params[:lot_label_printer_id]
    user.save
    redirect_to root_url
  end

end
