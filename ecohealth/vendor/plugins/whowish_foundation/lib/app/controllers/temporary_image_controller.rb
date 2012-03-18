class TemporaryImageController < ActionController::Base
 include ThumbnailismHelper
 
 def index
   
    if !@allow_extensions
      @allow_extensions = ["jpg","jpeg","gif","png"]
    end

    ok, filename, error_message = false,nil,nil
    
    if params[:Filedata].class == String
    
      data_bytes = request.body.read # will return a StringIO
      
      
      ok, filename, error_message = upload_temporary_image(data_bytes,params[:Filedata],data_bytes.length,@allow_extensions)
    else
      ok, filename, error_message = upload_temporary_image(params[:Filedata].read,params[:Filedata].original_filename,params[:Filedata].size,@allow_extensions)
    end
    
    #absolutely necessary, otherwise the browser will force download
    response.headers['Content-type'] = 'text/html; charset=utf-8'

    render :json=>{:ok=>ok, :filename=>filename,:error_message=>error_message}
    
  end
  
  def any_file
    @allow_extensions = ["zip","pdf","txt","doc","xls","rar"]
    
    index
  end
  
  def upload_temporary_image(image_data,original_filename,size,allowed_extensions)
    temp_image = TemporaryImage.new
    temp_image.name = ""
    temp_image.created_date = Time.now


    return false, nil, "The image cannot exceed 8MB" if size > 8000000
    return false, nil, "The database has failed." if !temp_image.save

    ext = File.extname( original_filename ).sub( /^\./, "" ).downcase

    if !allowed_extensions.include?(ext)
      return false, nil, "The extension (#{ext}) is not allowed."
    end
    
    temp_image.name = "temp_"+temp_image.id.to_s+"."+ext
    

    return false, nil, "The database has failed." if !temp_image.save

    
    begin
      if ENV['S3_ENABLED']
        
        AWS::S3::S3Object.store(get_server_path_of(temp_image.name), image_data, AWS_S3_BUCKET_NAME,:access=>:public_read)

      else
        
        File.open(RAILS_ROOT+"/public/uploads/"+temp_image.name, "wb") { |f| 
          f.write(image_data) 
        }
        
        File.chmod(0777, get_server_path_of("/uploads/"+temp_image.name)) 
      end

      temp_image.created_date = Time.now
      temp_image.save
      
      return true, "/uploads/#{temp_image.name}", nil
    rescue Exception=>e
      
      if temp_image.name != ""
        begin
          delete_image(temp_image.name)
        rescue Exception=>ex
        end
      end
      
      return false, nil, "The uploading has failed. Please try again. #{e.to_s_with_trace}"
    end
    

  end
  
end
