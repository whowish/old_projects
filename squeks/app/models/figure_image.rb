class FigureImage < ActiveRecord::Base
  include ThumbnailismHelper

  def get_160x160_thumbnail_image_url(return_default=true)
    if self.original_image_path and self.original_image_path != ""
      if ENV['S3_ENABLED']
        return get_thumbnail_url("/uploads/"+self.original_image_path,160,160)
      else
        return self.original_image_path
      end
    end

    if return_default == false
      return nil
    end

    return "/images/defaultThumb160x160.jpg"
  end
end