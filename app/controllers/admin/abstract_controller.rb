class Admin::AbstractController < ApplicationController
  layout 'admin'
  
  before_filter :login_required
  
  def dashboard
    @user = current_user
  end
  
  protected
  def authorized?
    logged_in? && current_user.admin?
  end
  
end  