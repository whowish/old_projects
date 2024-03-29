module ThumbnailismHelper
  
  def make_thumbnail(file_path,w,h)

    file_path = get_server_path_of(file_path)
    
    if file_path.match("^"+RAILS_ROOT+"/public/") 
      file_path = file_path[(RAILS_ROOT+'/public/').length..-1]
    end
    
    
    
    new_file_name = file_path.gsub(/\//, '__')   
    

    thumbnail_path = get_server_path_of('/uploads/thumbnail/'+w.to_s+'x'+h.to_s+'/'+new_file_name)
    print "THumb: " + thumbnail_path + "\n"

    if !image_exists?(thumbnail_path)
      print "Filepath: " + file_path+"\n"
      if !image_exists?(get_server_path_of(file_path))
        return ''
      end

      image_resize(get_server_path_of(file_path), w.to_i, h.to_i, thumbnail_path)
    end

    
    return '/uploads/thumbnail/'+w.to_s+'x'+h.to_s+'/'+new_file_name
    
  end
  
  def image_obj_resize(image,w,h,mode='normal')
    ow,oh = image['%w %h'].split
    
    ow = ow.to_i
    oh = oh.to_i

    nw = w
    nh = h

    ratio = 1

    if (ow-nw) < (oh-nh)
      ratio = nw.to_f / ow.to_f
    else
      ratio = nh.to_f / oh.to_f
    end

    nw = ow*ratio
    nh = oh*ratio

    logger.debug { "ratio=#{ratio}" }
    logger.debug { "old_width=#{ow},old_height=#{oh}" }
    logger.debug { "new_width=#{nw},new_height=#{nh}" }

    image.resize "#{nw}x#{nh}"
   
    logger.debug { "shave height 0x" + ((nh-h)/2).to_i.to_s }
    logger.debug { "shave width " + ((nw-w)/2).to_i.to_s + "x0" }
    
    image.shave("0x" + ((nh-h)/2).to_i.to_s) if nh > h
    image.shave(((nw-w)/2).to_i.to_s + "x0") if nw > w
    
    return image
  end
  
  def image_resize(src, w, h, dest)

    logger.debug{"Enter image_resize()"}
    logger.debug{"src=#{src},w=#{w},h=#{h},dest=#{dest}"}

    ensure_path(dest)

    # start resizing
    w = w.to_i
    h = h.to_i

    require 'mini_magick'

    image = nil
    
    if ENV['S3_ENABLED']
      image = MiniMagick::Image.from_blob(AWS::S3::S3Object.stream(src, AWS_S3_BUCKET_NAME))
    else
      image = MiniMagick::Image.from_file(src)
    end
    
    
    image = image_obj_resize(image,w,h)

    begin
      if ENV['S3_ENABLED']
         AWS::S3::S3Object.store(dest,File.open(image.path,'rb'), AWS_S3_BUCKET_NAME,:access=>:public_read)
      else
        image.write dest
      end
    rescue Exception=>e
       logger.error{e.to_s_with_trace}
    end

    logger.debug{"Exit image_resize()"}
  end
  
  def ensure_path(dest)
    
    if ENV['S3_ENABLED']
      
    else
      #ensure directory structure
      dir = File.dirname(dest)
      print dir + "\n"
      
      token_dirs = dir.split('/')
      root_d = token_dirs[0]
      
      token_dirs[1..-1].each {|d|
        if !File.directory?(root_d+"/"+d)
          Dir.mkdir(root_d+"/"+d)
          File.chmod(0777, root_d+"/"+d)   
        end
        
        root_d = root_d+"/"+d
      }
    end
  end
  
  # a temp file: temp_*
  # a item file: item_*
  #
  def get_server_path_of(full_file_path)

    full_file_path = full_file_path[1..-1] if full_file_path.match("^/")
    
    prefixes = [RAILS_ROOT,"public","uploads"]
    tokens = []
    
    if ENV['S3_ENABLED'] == "true"
      prefixes = ["uploads"]
    end
    
    prefixes.each {|prefix|
      break if full_file_path.match("^"+prefix+"/")
      tokens.push(prefix) 
    }

    full_file_path = tokens.join('/') +"/"+ full_file_path
    
    full_file_path = full_file_path[1..-1] if full_file_path.match("^/") 

    
    return full_file_path
  end
  
  def get_thumbnail_url(full_file_path, w, h)
    full_file_path = get_server_path_of(full_file_path)

    full_file_path = full_file_path[(RAILS_ROOT+'/public/').length..-1] if full_file_path.match("^"+RAILS_ROOT+"/public/") 
    
    thumb_file_name = full_file_path.gsub(/\//, '__')  
    
    if ENV['S3_ENABLED']
      return "http://s3.amazonaws.com/"+AWS_S3_BUCKET_NAME+"/uploads/thumbnail/"+w.to_s+"x"+h.to_s+"/"+ thumb_file_name
    else
      return "/uploads/thumbnail/"+w.to_s+"x"+h.to_s+"/"+ thumb_file_name
    end
    
  end
  
  def delete_all_thumbnail_image(full_file_path)
    full_file_path = get_server_path_of full_file_path
    
    new_file_name = full_file_path.gsub(/\//, '__')
    
    THUMBNAIL_SIZES.each { |size| 
       full_path = get_server_path_of("/thumbnail/"+size+"/"+new_file_name)
        if image_exists?(full_path)
          begin
            if ENV['S3_ENABLED']
              AWS::S3::S3Object.delete(full_path, AWS_S3_BUCKET_NAME)
            else
              File.delete(full_path)
            end
          rescue
          end
        end
    }

  end
  
  def delete_image(full_file_path)
    
    full_file_path = get_server_path_of full_file_path
    
    delete_all_thumbnail_image(full_file_path)
    
    begin
      if ENV['S3_ENABLED'] == "true"
        AWS::S3::S3Object.delete(full_file_path, AWS_S3_BUCKET_NAME)
      else
        File.delete(full_file_path)
      end
    rescue
    end

  end

  def image_exists?(file)
    if ENV['S3_ENABLED']
      #print AWS::S3::S3Object.exists?(get_server_path_of(file), AWS_S3_BUCKET_NAME).to_s + " " + get_server_path_of(file)+"\n\n"
      return AWS::S3::S3Object.exists?(get_server_path_of(file), AWS_S3_BUCKET_NAME)
    else
      print File.exists?(get_server_path_of(file)).to_s + " " + get_server_path_of(file)+"\n\n"
      return File.exists?(get_server_path_of(file))
    end
  end
  
  def image_copy(src,dest)
    if ENV['S3_ENABLED']
      AWS::S3::S3Object.copy(get_server_path_of(src), get_server_path_of(dest), AWS_S3_BUCKET_NAME,{:access=>:public_read})
    else
      require 'ftools'
      File.copy(get_server_path_of(src),get_server_path_of(dest))  
      File.chmod(0777, get_server_path_of(dest)) 
    end
  end
end