class TemporaryImageController < ActionController::Base
 include ThumbnailismHelper
 
 def index

    ok, filename, error_message = upload_temporary_image(params[:Filedata])

    #absolutely necessary, otherwise the browser will force download
    response.headers['Content-type'] = 'text/plain; charset=utf-8'

    render :json=>{:ok=>ok, :filename=>filename,:error_message=>error_message}
    
  end
  
  def upload_temporary_image(image_data)
    temp_image = TemporaryImage.new
    temp_image.name = ""
    temp_image.created_date = Time.now


    return false, nil, "The image cannot exceed 4MB" if image_data.size > 4000000
    return false, nil, "The database has failed." if !temp_image.save

    ext = File.extname( image_data.original_filename ).sub( /^\./, "" ).downcase

    if !["jpg","jpeg","gif","png"].include?(ext)
      return false, nil, "The extension (#{ext}) is not allowed."
    end
    
    temp_image.name = "temp_"+temp_image.id.to_s+"."+ext
    

    return false, nil, "The database has failed." if !temp_image.save

    
    begin
      if ENV['S3_ENABLED']
        
        AWS::S3::S3Object.store(get_server_path_of(temp_image.name), image_data.read, AWS_S3_BUCKET_NAME,:access=>:public_read)

      else
        
        File.open(RAILS_ROOT+"/public/uploads/"+temp_image.name, "wb") { |f| 
          f.write(image_data.read) 
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
      
      return false, nil, "The uploading has failed. Please try again. #{e}"
    end
    

  end
  
end
