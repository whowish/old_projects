require 'mini_magick'

module ThumbnailismHelper

  # Resize to w x h
  # If w > 0 and h > 0, then we apply ratios and the crop to the specified size
  # If w == 0, then we apply only height ratio
  # If h == 0, then we apply only width ratio
  def image_obj_resize(image, w, h, only_if_exceed=false)
    
    ow, oh = image['%w %h'].split
    ow, oh = ow.to_i, oh.to_i
    
    return image if only_if_exceed == true and  ow < w

    nw, nh = w, h
    w_ratio = nw.to_f / ow.to_f
    h_ratio = nh.to_f / oh.to_f
    
    ratio = [w_ratio,h_ratio].max
    
    nw, nh = ow*ratio, oh*ratio

    image.resize "#{nw}x#{nh}"
    
    image.shave("0x" + ((nh-h)/2).to_i.to_s) if nh > h and h > 0
    image.shave(((nw-w)/2).to_i.to_s + "x0") if nw > w and w > 0
    
    return image
    
  end
  
  def image_resize(src, w, h, dest, only_if_exceed=false)
    
    w, h = w.to_i, h.to_i

    ensure_path(dest)
    
    image = MiniMagick::Image.from_file(src)
    image = image_obj_resize(image,w,h,only_if_exceed)

    begin
      image.write dest
    rescue Exception=>e
       Rails.logger.error{e.to_s_with_trace}
       raise e
    end

  end
  
end