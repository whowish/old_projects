module TemporaryFileHelper
  include ThumbnailismHelper
  
  def ensure_path(dest)
    
    dir = File.dirname(dest)

    token_dirs = dir.split('/')
    root_d = token_dirs[0]
    
    token_dirs[1..-1].each {|d|
    
      this_path = "#{root_d}/#{d}"
      if !File.directory?(this_path)
        Dir.mkdir(this_path)
        File.chmod(0777, this_path)   
      end
      
      root_d = this_path
    }

  end
  
  private
  def upload_temporary_image(image_data,original_filename,size,allowed_extensions,options={})
    
    raise "The image cannot exceed 20MB" if size > 20000000

    ext = File.extname( original_filename ).sub( /^\./, "" ).downcase

    if !allowed_extensions.include?(ext)
      raise "The extension (#{ext}) is not allowed. Only #{allowed_extensions.join(", ")} are allowed."
    end
    
    temp_image = TemporaryFile.new
    temp_image.name = ""
    temp_image.created_date = Time.now
    raise "The database has failed." if !temp_image.save
    
    temp_image.name = "/uploads/temp/#{File.basename(original_filename,".#{ext}")}-#{temp_image.id}.#{ext}"
    raise "The database has failed." if !temp_image.save

    begin
        
      path = File.join(Rails.root, "public", temp_image.name)
      
      ensure_path(path)
      File.open(path, "wb") { |f| 
        f.write(image_data) 
      }
      
      File.chmod(0777, path)
      
      if ["jpg","jpeg","gif","png"].include?(ext) and options[:max_width]
        image_resize(path, 
                      options[:max_width].to_i, 
                      0, 
                      path,
                      true)
      end

      temp_image.created_date = Time.now
      temp_image.save
      
      return temp_image.name
      
    rescue Exception=>e
      
      (FileUtils.remove(temp_image.name) rescue "") \
                if temp_image.name != ""
 
      raise "The uploading has failed. Please try again. #{e.to_s} (#{e.backtrace[0]}"
      
    end
    

  end

end