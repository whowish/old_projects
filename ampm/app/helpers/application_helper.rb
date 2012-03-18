# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ThumbnailismHelper
  include FacebookHelper
  include Foundation
  
  def semantic_day(time)
    semantic_day = time.strftime("%d %B %Y")
    today_int = Time.now.to_i / (60 * 60 * 24)
    time_int = time.to_i / (60 * 60 * 24)
    
    if today_int.to_i == time_int.to_i
      semantic_day = "Today"
    elsif today_int.to_i == time_int.to_i + 1
      semantic_day = "Yesterday"
    elsif today_int.to_i == time_int.to_i - 1
      semantic_day = "Tomorrow"
    end
      
    return semantic_day
  end
end
