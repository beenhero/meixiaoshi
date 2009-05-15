class OrdersController < ApplicationController

  def new
    @service = Service.find(params[:service_id])
    @user = @service.user
    @order = Order.new(:description => "时间：\n地点：\n任务：")
    
    respond_to do |format|
      format.js { render :partial => 'form'}
    end
  end

  def edit
    @order = Order.find(params[:id])
    render :partial => "edit"
  end

  def create
    @service = Service.find(params[:order][:service_id])
    @user = @service.user
    @order = @service.orders.new(params[:order].merge(:user_id => @user.id))
    
    respond_to do |format|
      if @order.save
        format.js   { render :text => "订单提交成功，卖家收到后会联系你！欢迎反馈各类意见，谢谢！" }
      else
        format.js   { render :partial => 'form'}
      end
    end
  end

  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order].merge(:replied_at => Time.now))
        format.js   { render :text => "保存成功，进入邮件发送队列！" }
      else
        format.js   { render :partial => "edit" }
      end
    end
  end
  
  def replied
    if request.xhr?
      @order = Order.find(params[:id])
      @order.replied_at = Time.now
      @order.save
      render :nothing => true
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.deleted_at = Time.now
    @order.save
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page["order_#{@order.id}"].visual_effect :highlight, :duration => 1
          page["order_#{@order.id}"].visual_effect :fade
        end
      end
    end
  end
end
