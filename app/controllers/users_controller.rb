class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :login_required, :only => [:edit, :edit_info, :edit_contacts, :edit_password, :update, :destroy]
  before_filter :find_user, :only => [:show, :edit, :edit_info, :edit_contacts, :edit_password, :update, :destroy, :calendar]
  
  def show
    @services = @user.services
    @display_date = Date.new(Date.today.year, Date.today.month, 1)
  end
  
  def new
    logout_keeping_session!
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    if using_open_id?
      authenticate_with_open_id(params[:openid_url], :return_to => open_id_create_url, 
        :required => [:nickname, :email]) do |result, identity_url, registration|
        if result.successful?
          create_new_user(:identity_url => identity_url, :login => registration['nickname'], :email => registration['email'])
        else
          failed_creation(result.message || "Sorry, something went wrong")
        end
      end
    else
      create_new_user(params[:user])
    end
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "帐号激活成功，请登录开始出售时间."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "激活码不正确，请点击发送到你邮箱的激活链接."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "激活码不对，请检查邮件校对激活链接，或者可能你已经激活，请尝试登录."
      redirect_back_or_default(root_path)
    end
  end
  
  def edit
    @user.user_info ||= @user.build_user_info
  end
  
  def edit_info
    @user.user_info ||= @user.build_user_info
    @user.address ||= @user.build_address(:province_id => '330000')
    
    #assign some default values to address
    @province = @user.address.province || Province.find_by_name('浙江省')
    @cities = @province.cities
    @counties = @user.address.city ? @user.address.city.counties : @cities.first.counties
    @areas = @user.address.county ? @user.address.county.areas : @counties.first.areas
    
    if request.put?
      @user.user_info.update_attributes(params[:user_info])
      @user.address.update_attributes(params[:user_address])
    end
  end
  
  def edit_contacts   
    @user.phone_numbers.build(:contact_type => 'PHONE', :name => 'mobile') and @user.save if @user.phone_numbers.empty?
    @user.instant_messages.build(:contact_type => 'IM', :name => 'qq') and @user.save if @user.instant_messages.empty?
    @user.snses.build(:contact_type => 'SNS', :name => 'blog') and @user.save if @user.snses.empty?
    
    if request.put?
      @user.update_attributes(params[:user])
      redirect_to  edit_contacts_user_path(@user)
    end
  end
  
  def edit_password
    if request.put?
      if params[:old_password].empty?
        flash[:warning] = "请输入旧密码."
        render :action => 'edit_password'
      elsif @user.authenticated?(params[:old_password])
        @user.attributes = params[:user]

        if @user.save
          flash[:notice] = "密码修改成功."
          redirect_to edit_password_user_path(@user)
        end
      else
        flash[:error] = "旧密码错误，请重试."
        render :action => 'edit_password'
      end
    end     
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_password'
  end
  
  def update
    @user.update_attributes(params[:user])
    redirect_to edit_user_path(@user)
  end
  
  def destroy
    
  end
  
  def check_login
    if request.xhr?
      render :text => User.check_login?(params[:login]) ? "<span class='ok'>好 !!!</span>" : "<span class='not_ok'>无效，请更换</span>"
    end
  end
  
  def calendar
    if request.xhr?
      y = params.include?(:year) ? params[:year].to_i : Date.today.year
      m = params.include?(:month) ? params[:month].to_i : Date.today.month
      @display_date = Date.new(y, m, 1)
      render :partial => 'calendar', :locals => { :highlighted => true, :user => @user}
    end # only response for XHR
  end
  
  protected
  
  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      if @user.not_using_openid?
        @user.register!
      else
        @user.register_openid!
      end
    end
    
    if @user.errors.empty?
      successful_creation(@user)
    else
      failed_creation
    end
  end
  
  def successful_creation(user)
    redirect_back_or_default(root_path)
    flash[:notice] = "感谢注册!"
    flash[:notice] << " 激活帐号链接已经发送到你的邮箱." if @user.not_using_openid?
    flash[:notice] << " You can now login with your OpenID." unless @user.not_using_openid?
  end
  
  def failed_creation(message = '对不起, 发生了错误')
    flash[:error] = message
    render :action => :new
  end
end
