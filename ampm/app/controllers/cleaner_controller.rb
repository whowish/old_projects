class CleanerController < ActionController::Base
  
  def index
    
    events = Event.all(:conditions=>["status=? AND settled_date < CURDATE()",Event::STATUS_SETTLED])
    
    ids = []
    events.each { |event|
      check = EventSettledDate.first(:conditions=>["id=? AND settled_date > CURDATE()",event.id])
      
      ids.push(event.id) if !check
    }
    
    # clear expired items
    Event.update_all(["status=?",Event::STATUS_COMPLETED],["id in (?)",ids])

    render :text=>"OK"
  
  end
end
