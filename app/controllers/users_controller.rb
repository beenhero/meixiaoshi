class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
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
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @user.user_info ||= @user.build_user_info
  end
  
  def edit_info
    @user = User.find(params[:id])
    @user.user_info ||= @user.build_user_info
    @user.address ||= @user.build_address
    
    #assign some default values to address
    @province = @user.address.province || Province.find_by_name('浙江省')
    @cities = @province.cities
    @counties = @user.address.city.counties || @cities.first.counties
    @areas = @user.address.county.areas || @counties.first.areas
    
    if request.put?
      @user.user_info.update_attributes(params[:user_info])
      @user.address.update_attributes(params[:user_address])
    end
  end
  
  def edit_contacts
    @user = User.find(params[:id])
   
    @user.phone_numbers.build(:contact_type => 'PHONE', :name => 'mobile') and @user.save if @user.phone_numbers.empty?
    @user.instant_messages.build(:contact_type => 'IM', :name => 'qq') and @user.save if @user.instant_messages.empty?
    @user.snses.build(:contact_type => 'SNS', :name => 'blog') and @user.save if @user.snses.empty?
    
    if request.put?
      @user.update_attributes(params[:user])
      redirect_to  edit_contacts_user_path(@user)
    end
  end
  
  def edit_password
    @user = User.find(params[:id])
    if request.put?
      if params[:old_password].empty?
        flash[:notice] = "请输入旧密码."
        render :action => 'edit_password'
      elsif @user.authenticated?(params[:old_password])
        @user.attributes = params[:user]

        if @user.save
          flash[:notice] = "密码修改成功."
          redirect_to edit_password_user_path(@user)
        end
      else
        flash[:notice] = "旧密码错误，请重试."
        render :action => 'edit_password'
      end
    end     
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_password'
  end
  
  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    redirect_to edit_user_path(@user)
  end
  
  def destroy
    
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
    flash[:notice] = "Thanks for signing up!"
    flash[:notice] << " We're sending you an email with your activation code." if @user.not_using_openid?
    flash[:notice] << " You can now login with your OpenID." unless @user.not_using_openid?
  end
  
  def failed_creation(message = 'Sorry, there was an error creating your account')
    flash[:error] = message
    render :action => :new
  end
end
