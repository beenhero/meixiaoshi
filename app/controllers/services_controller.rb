class ServicesController < ApplicationController

  def index
    @services = Service.find :all
  end
  
  def show
    @service = Service.find(params[:id])
    @start_date = @service.begin_date_time.to_date.beginning_of_week
  end
  
  def new
    @user = current_user
    @service = @user.services.build(:begin_date_time => Time.now, :end_date_time => Time.now + 2.hours, :repeat_until => Date.today.next_month, :location => @user.address.single_line)
  end
  
  def create
    @user = current_user
    @service = @user.services.build(params[:service].merge(:end_date_string => params[:service][:begin_date_string]))
  
    if @service.save
      flash[:notice] = "发布成功，开始出售你的时间"
      redirect_to services_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user = current_user
    @service = Service.find(params[:id])
  end
  
  def update
    @service = Service.find(params[:id])
    @service.update_attributes(params[:service].merge(:end_date_string => params[:service][:begin_date_string]))
    render :action => "edit"
  end
  
  def schedules
    if request.xhr? && !params[:start_date].blank?
      @service = Service.find(params[:id])
      @user = @service.user
      @start_date = Date.parse(params[:start_date])
      render :partial => "schedules", :locals => { :highlighted => true }
    end # only response for XHR
  end
  
end