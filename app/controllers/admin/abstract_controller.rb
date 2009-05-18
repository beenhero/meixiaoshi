class Admin::AbstractController < ApplicationController
  layout 'admin'
  
  before_filter :login_required
  
  def dashboard
    @user = current_user
  end
  
  protected
  def authorized?
    admin?
  end
  
end  