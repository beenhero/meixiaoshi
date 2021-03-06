class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  protected
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
  
  def find_user
    if @user = User.find(params[:user_id] || params[:id])
      @is_owner = (@user && @user.eql?(current_user))
      return @user
    else
      flash.now[:error] = "请先登录."
      redirect_to login_path
      return false
    end
  end
  
  def admin?
    logged_in? && current_user.admin?
  end
  
  def access_denied
    flash[:warning] = "没有权限访问"
    redirect_to root_path
  end
end

