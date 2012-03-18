require 'fileutils'

class TemporaryFileController < ActionController::Base
  include TemporaryFileHelper
  include ThumbnailismHelper
 
  def index
   
    #absolutely necessary, otherwise the browser will force download
    response.headers['Content-type'] = 'text/html; charset=utf-8'
   
    if !@allow_extensions
      render :json=>{:ok=>false, :error_message=>"Invalid path. Please use /temporary_file/image or /temporary_file/any_file"}
      return
    end
    
    @options = {}
    if params[:max_width]
      @options[:max_width] = params[:max_width]
    end

    begin 
      
      if params[:Filedata].class == String
        
        data_bytes = request.body.read
        filename = upload_temporary_image(data_bytes,
                                          params[:Filedata],
                                          data_bytes.length,
                                          @allow_extensions,
                                          @options)
      
      else
        
        filename= upload_temporary_image(params[:Filedata].read,
                                          params[:Filedata].original_filename,
                                          params[:Filedata].size,
                                          @allow_extensions,
                                          @options)
      
      end
    
      render :json=>{:ok=>true, :filename=>filename}
      
    rescue Exception=>e
      
      render :json=>{:ok=>false, :error_messages=>e.message}
      
    end

  end

  def image
   
    @allow_extensions = ["jpg","jpeg","gif","png"]
    index
    
  end
  
  def any_file
    
    @allow_extensions = ["zip","pdf","txt","doc","xls","rar","jpg","jpeg","gif","png"]
    index
    
  end
  
  
  
end
