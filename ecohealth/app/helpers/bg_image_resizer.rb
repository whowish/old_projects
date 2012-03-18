class BgImageResizer
  include ThumbnailismHelper
  def perform
    
    Activity.all.each { |entity|
      ActivityImage.all(:conditions=>{:activity_id=>entity.id}).each { |image|
        THUMBNAIL_SIZES.each { |size|
            tokens = size.split('x')
            make_thumbnail(image.original_image_path, tokens[0].to_i, tokens[1].to_i)
        }
      }
    }
    
    Conference.all.each { |entity|
     ConferenceImage.all(:conditions=>{:conference_id=>entity.id}).each { |image|
        THUMBNAIL_SIZES.each { |size|
            tokens = size.split('x')
            make_thumbnail(image.original_image_path, tokens[0].to_i, tokens[1].to_i)
        }
      }
    }
    
    Research.all.each { |entity|
     ResearchImage.all(:conditions=>{:research_id=>entity.id}).each { |image|
        THUMBNAIL_SIZES.each { |size|
            tokens = size.split('x')
            make_thumbnail(image.original_image_path, tokens[0].to_i, tokens[1].to_i)
        }
      }
    }
    
  end
end