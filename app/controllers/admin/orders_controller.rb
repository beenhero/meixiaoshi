class Admin::OrdersController < Admin::AbstractController
  before_filter :find_order, :only => [:edit, :show, :update, :destroy]
  
  def index
    @orders = Order.valid.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
  end
  
  def deleted
    @orders = Order.deleted.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
    render :template => "admin/orders/index"
  end
  
  def delayed
    @orders = Order.delayed.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
    render :template => "admin/orders/index"
  end
  
  def show
    
  end
  
  def edit

  end
  
  def update
    @order.attributes = params[:order]
    if @order.save
      flash[:notice] = "保存成功！"
      redirect_to edit_admin_order_path(@order)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
    @order.deleted_at = Time.now
    @order.save
    redirect_to admin_orders_path
  end
  
  protected
  def find_order
    @order = Order.find(params[:id])
  end
end