class MosaicGenerator
  include ThumbnailismHelper

  attr_accessor :image_url
  attr_accessor :facebook_id

  def initialize(facebook_id,image_url)
    self.facebook_id = facebook_id
    self.image_url = image_url
  end

  def perform
    require 'mini_magick'

    logger.debug { "MosaicGenerator.perform()" }
    logger.debug { "image_url=#{self.image_url},facebook_id=#{self.facebook_id}" }

    begin
      image = MiniMagick::Image.from_url(self.image_url)

      image.resize "10%"
      image.resize "1000%"

      member = Member.first(:conditions=>{:facebook_id=>self.facebook_id})

      dest = "/uploads/member_"+member.id.to_s+".jpg"
      ensure_path(dest)

      if ENV['S3_ENABLED']
        AWS::S3::S3Object.store(dest,File.open(image.path,'rb'), AWS_S3_BUCKET_NAME,:access=>:public_read)
      else
        image.write dest
      end

      member.anonymous_profile_pic = dest
      member.updated_date = Time.now
      member.save

      logger.debug { "Create Mosaic thumbnail successfully" }
    rescue Exception=>e
      logger.warn {e.to_s_with_trace}
    end

    logger.debug { "Done" }

  end
end