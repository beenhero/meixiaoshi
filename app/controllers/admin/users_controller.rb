class Admin::UsersController < Admin::AbstractController
  before_filter :find_user, :only => [:show, :edit, :update, :edit_info, :edit_contacts, :edit_password, :destroy, :renew]
  
  def index
    @users = User.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
  end
  
  def pending
    @users = User.pending.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
    render :template => "admin/users/index"
  end
  
  def deleted
    @users = User.deleted.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
    render :template => "admin/users/index"
  end
  
  def show
    
  end
  
  def edit
    
  end
  
  def update
    @user.spammer = params[:user][:spammer]
    if @user.update_attributes(params[:user])
      flash[:notice] = "保存成功！"
      redirect_to edit_admin_user_path(@user)
    else
      render :action => "edit"
    end
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
      redirect_to  edit_contacts_admin_user_path(@user)
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
          redirect_to edit_password_admin_user_path(@user)
        end
      else
        flash[:error] = "旧密码错误，请重试."
        render :action => 'edit_password'
      end
    end     
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_password'
  end
  
  def destroy
    if @user.delete!
      flash[:notice] = "用户已标记删除."
      redirect_to deleted_admin_users_path
    end
  end
  
  def renew
    if @user.renew!
      flash[:notice] = "恢复成功！"
      redirect_to admin_users_path
    end
  end
  
end
