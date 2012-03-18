class TemporaryImageController < ActionController::Base
 include ThumbnailismHelper
 
 def index

    return_json = upload_temporary_image(params[:Filedata])

    response.headers['Content-type'] = 'text/plain; charset=utf-8'
    
    print return_json.inspect
    
    render :json=>return_json
    
  end
  
  def upload_temporary_image(image_data)
    temp_image = TemporaryImage.new
    temp_image.name = ""
    temp_image.created_date = Time.now
    
    if !temp_image.save
      return {:ok=>false, :error_message=>"The database has failed."}
    end
    
    ext = File.extname( image_data.original_filename ).sub( /^\./, "" ).downcase

    if !["jpg","jpeg","gif","png"].include?(ext)
      return {:ok=>false, :error_message=>"The extension ("+ext+") is not allowed."}
    end
    
    temp_image.name = "temp_"+temp_image.id.to_s+"."+ext
    
    if !temp_image.save
      return {:ok=>false, :error_message=>"The database has failed."}
    end
    
    begin
      if ENV['S3_ENABLED']
        
        AWS::S3::S3Object.store(get_server_path_of(temp_image.name), image_data.read, AWS_S3_BUCKET_NAME,:access=>:public_read)

      else
        
        File.open(RAILS_ROOT+"/public/uploads/"+temp_image.name, "wb") { |f| 
          f.write(image_data.read) 
        }
        
        File.chmod(0777, get_server_path_of("/uploads/"+temp_image.name)) 
      end

      #image_resize("public/uploads/temp/"+temp_image.name, 112, 112, "public/uploads/temp/"+thumbnailize_name(temp_image.name,112,112))
      temp_image.created_date = Time.now
      temp_image.save
      
      return {:ok=>true, :filename=>"/uploads/"+temp_image.name}
    rescue Exception=>e
      
      if temp_image.name != ""
        begin
          delete_image(temp_image.name)
        rescue Exception=>ex
        end
      end
      
      return {:ok=>false, :error_message=>"The uploading has failed. Please try again. "+e}
    end
    

  end
  
end
