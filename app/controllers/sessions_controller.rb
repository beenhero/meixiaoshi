class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
    logout_keeping_session!
  end

  def create
    logout_keeping_session!
    if using_open_id?
      open_id_authentication
    else
      password_authentication
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "你已经成功退出."
    redirect_back_or_default(root_path)
  end
  
  def open_id_authentication
    authenticate_with_open_id do |result, identity_url|
      if result.successful? && self.current_user = User.find_by_identity_url(identity_url)
        successful_login
      else
        flash[:error] = result.message || "Sorry no user with that identity URL exists"
        @remember_me = params[:remember_me]
        render :action => :new
      end
    end
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_user = user
      successful_login
    end
  rescue User::LoginError => e
    note_failed_signin(e.message)
    @login = params[:login]
    @remember_me = params[:remember_me]
    render :action => :new
  end
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    redirect_back_or_default(root_path)
    flash[:notice] = "登录成功"
  end

  def note_failed_signin(message)
    flash[:error] = "#{message}"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}: #{message}"
  end
end
