# encoding: utf-8
module ApplicationHelper
  
  def semantic_time(time)
    semantic_time = ""
    prefix = ""
    suffix = "ที่แล้ว"
    
    duration = Time.now - time
    
    if duration < 0
      prefix = "อีก "
      suffix = ""
      duration = -duration
    end
   
    if duration >= 0 and duration < 60
        semantic_time = prefix + duration.to_f.round.to_s + " วินาที" + suffix
    
    elsif duration >= 60 and duration < (60 * 60)
        semantic_time = prefix + (duration / 60).to_f.round.to_s + " นาที" + suffix
    
    elsif duration >= (60 * 60) and duration < (60 * 60 * 24)
        semantic_time = prefix + (duration / (60 * 60)).to_f.round.to_s + " ชัวโมง" + suffix
    
    elsif duration >= (60 * 60 * 24) and duration < (60 * 60 * 24 * 30)
        semantic_time = prefix + (duration / (60 * 60 * 24)).to_f.round.to_s + " วัน" + suffix
    
    elsif duration >= (60 * 60 * 24 * 30) and duration < (60 * 60 * 24 * 30 * 12)
        semantic_time = prefix + (duration / (60 * 60 * 24 * 30)).to_f.round.to_s + " เดือน" + suffix
      
    elsif duration >= (60 * 60 * 24 * 30 * 12)
        semantic_time = prefix + (duration / (60 * 60 * 24 * 30 * 12)).to_f.round.to_s + " ปี" + suffix
      
    end
      
    return semantic_time
  end
  
  def strip_all_params
    params.each_pair { |k,v|
      params[k] = v.strip if v != nil
    }
  end
end
