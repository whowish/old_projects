class AdminController < ApplicationController
  include OrderHelper
  include AdminHelper
  
  def check_confirm_transfer
    order_ids = params[:order_id].split(',');
    order_ids.each do |o|
      order = Order.first(:conditions=>{:id => o})
      successfully_order(order, Order::PAYMENT_TYPE_TRANSFER)
    end
    render :json=>{:ok=>true}
  end
  
  def test
    
    require 'zip/zip'
     
    path = "#{RAILS_ROOT}/public/uploads/t_#{Time.now.to_f}.zip"
    
    # Give the path of the temp file to the zip outputstream, it won't try to open it as an archive.
    Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.add("fb.jpg", "#{RAILS_ROOT}/public/images/logo75x75.png")
    end
    
    
    
    # End of the block  automatically closes the file.
    # Send it using the right mime type, with a download window and some nice file name.
    send_file path, :type => 'application/zip', :disposition => 'attachment', :filename => "order_#{Time.now.to_f}.zip"
    
    
  end
  
  def print_order
    
    order_ids = params[:order_id].split(',');
    
    render :text=>"Please select at least one order" and return if order_ids.length == 0
    
    zip_name = "order_#{order_ids.length}_#{Time.now.strftime("%Y-%m-%d_%H_%M_%S")}_#{rand()}.zip"
    zip_file_path = "#{RAILS_ROOT}/public/uploads/#{zip_name}"

    require 'zip/zip'
    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      order_ids.each do |o|
        order = Order.first(:conditions=>{:id => o})
        
        filename = order.print_image_url.split('/')[-1]
        
        zipfile.add("#{order.key}.jpg","#{RAILS_ROOT}/public/uploads/#{filename}")
      end
    end

    
    order_ids.each do |o|
      order = Order.first(:conditions=>{:id => o})
      if !order.status == Order::STATUS_SHIPPING
        order.status = Order::STATUS_PRINTING 
        order.print_time = Time.now
        order.save
      end
    end
    
    render :json=>{:ok=>true,:redirect_url=>"/uploads/#{zip_name}"}
  end
  
  def ship_order
    order_ids = params[:order_id].split(',');
    order_ids.each do |o|
      order = Order.first(:conditions=>{:id => o})
      order.status = Order::STATUS_SHIPPING
      order.ship_time = Time.now
      order.save
    end
    render :json=>{:ok=>true}
  end
  def cancel_order
    order_ids = params[:order_id].split(',');
    order_ids.each do |o|
      order = Order.first(:conditions=>{:id => o})
      order.status = Order::STATUS_CANCELLED
      order.save
    end
    render :json=>{:ok=>true}
  end
  
  def regenerate
     order = Order.first(:conditions=>{:key => params[:order_key]})
     regenarate_image(order)
     render :json=>{:ok=>true}
  end
  
  def check_paypal_payment
    orders = Order.all(:conditions =>["status = :status and not(paypal_pay_key is null)",{:status=>Order::STATUS_PENDING}])
    orders.each do |order|
      if confirm_payment(order)
      Lock.generate("Paypal",order.key).synchronize {
        if order.status == Order::STATUS_PENDING
          successfully_order(order,Order::PAYMENT_TYPE_PAYPAL)
        end
      }
      end
    end
    render :json=>{:ok=>true}
  end
end
