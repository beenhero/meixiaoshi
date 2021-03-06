class Admin::ServicesController < Admin::AbstractController
  before_filter :find_service, :only => [:edit, :show, :update, :approve, :deny, :suspend, :unsuspend, :destroy]
  
  def index
    @services = Service.active.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
  end
  
  def show
    
  end
  
  def edit
    @user = @service.user
  end
  
  def update
    @service.attributes = params[:service].merge(:end_date_string => params[:service][:begin_date_string])
    @user = @service.user
    if @service.save
      flash[:notice] = "保存成功！"
      redirect_to edit_admin_service_path(@service)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    if request.xhr?
      @service.delete!
      render :partial => "action"
    else
      state = @service.state
      @service.delete!
      case state
      when "pending"
        redirect_to pending_admin_services_path
      when "active"
        redirect_to admin_services_path
      when "passive"
        redirect_to passive_admin_services_path
      when "suspended"
        redirect_to suspended_admin_services_path
      when "deleted"
        redirect_to deleted_admin_services_path
      end
    end
  end
  
  def approve
    if request.xhr?
      @service.activate!
      render :partial => "action"
    end
  end
  
  def deny
    if request.xhr?
      @service.deny!
      render :partial => "action"
    end
  end
  
  def suspend
    if request.xhr?
      @service.suspend!
      render :partial => "action"
    end
  end
  
  def unsuspend
    if request.xhr?
      @service.unsuspend!
      render :partial => "action"
    end
  end
  
  def pending
    @services = Service.pending.paginate(:page => params[:page], :per_page => 20, :order => "created_at ASC")
    render :template => "admin/services/index"
  end
  
  def passive
    @services = Service.passive.paginate(:page => params[:page], :per_page => 20, :order => "updated_at DESC")
    render :template => "admin/services/index"
  end
  
  def deleted
    @services = Service.deleted.paginate(:page => params[:page], :per_page => 20, :order => "deleted_at DESC")
    render :template => "admin/services/index"
  end
  
  def suspended
    @services = Service.suspended.paginate(:page => params[:page], :per_page => 20, :order => "deleted_at DESC")
    render :template => "admin/services/index"
  end
  
  protected
  def find_service
    @service = Service.find(params[:id])
  end
end  