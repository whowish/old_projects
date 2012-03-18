class ThumbnailController < ActionController::Base
  include ThumbnailismHelper
  
  def index
    
    if !(params[:size] =~ /[0-9]{1,4}x[0-9]{1,4}/)
      render :text=>"Invalid size"
      return
    end

    tokens = params[:size].split('x')
    w = tokens[0].to_i
    h = tokens[1].to_i
    
    print "\n\n\n" + params[:file] + "\n\n\n"
    
    url = make_thumbnail(params[:file],w,h)
    
    if url == '' or !image_exists?(url)
      render :text=>"Not found"
    else
      if ENV['S3_ENABLED']
        redirect_to 'http://s3.amazonaws.com/'+AWS_S3_BUCKET_NAME+url+'?'+Time.now.to_i.to_s
      else
        redirect_to url
      end
      
    end
  end
end
