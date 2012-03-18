class ImageResizer
  include ThumbnailismHelper

  attr_accessor :image_path

  def initialize(image_path)
    self.image_path = image_path
  end

  def perform
    require 'mini_magick'

    logger.debug { "ImageResizer.perform()" }
    logger.debug { "image_path=#{self.image_path}" }

    begin

      THUMBNAIL_SIZES.each { |size|
          tokens = size.split('x')
          logger.debug { "Resize #{tokens}" }
          make_thumbnail(self.image_path, tokens[0].to_i, tokens[1].to_i)
      }

    rescue Exception=>e
      logger.warn {e.to_s_with_trace}
    end

    logger.debug { "Done" }

  end
end