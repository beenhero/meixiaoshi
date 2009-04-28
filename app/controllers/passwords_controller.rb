class PasswordsController < ApplicationController
  def new
    @password = Password.new
  end

  def create
    @password = Password.new(params[:password])
    @password.user = User.find_by_email(@password.email)
    
    if @password.save
      PasswordMailer.deliver_forgot_password(@password)
      flash[:notice] = "已经发送重设链接，请查收你的邮箱 #{@password.email}."
      redirect_to :action => :new
    else
      render :action => :new
    end
  end

  def reset
    begin
      @user = Password.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.now]).user
    rescue
      flash[:notice] = '重设链接无效.'
      redirect_to new_password_path
    end    
  end

  def update_after_forgetting
    @user = Password.find_by_reset_code(params[:reset_code]).user
    
    if @user.update_attributes(params[:user])
      flash[:notice] = '密码重设成功.'
      redirect_to login_path
    else
      flash[:notice] = 'EPIC FAIL!'
      redirect_to :action => :reset, :reset_code => params[:reset_code]
    end
  end
  
  def update
    @password = Password.find(params[:id])

    if @password.update_attributes(params[:password])
      flash[:notice] = '密码更新成功.'
      redirect_to(@password)
    else
      render :action => :edit
    end
  end
end
