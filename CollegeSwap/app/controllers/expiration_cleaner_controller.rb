class ExpirationCleanerController <  ActionController::Base
  include ThumbnailismHelper
  
  def index

    # clear expired items
    Item.update_all("status='EXPIRED'","expiration_date < DATE_ADD( CURDATE( ) , INTERVAL 1 DAY ) AND NOT(expiration_date IS NULL) AND status = 'ACTIVE'")

    # clear temporary images
    temp_names = []
    TemporaryImage.all(:conditions=>["created_date < ?",(Time.now.utc - 60*60*3)]).each {|temp_image|
      Delayed::Job.enqueue temp_image
      temp_names.push(temp_image.name)
    }

    render :text=>"OK " + temp_names.join(' ')
    
    
  end
  
end
