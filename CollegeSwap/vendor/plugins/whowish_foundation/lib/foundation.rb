module Foundation
  
  def format_currency(number)
    return number_to_currency(number, :unit => '$', :separator => '.', :delimiter => ',', :format => '%u%n')
  end
  
  def semantic_time(time)
    semantic_time = ""
    suffix = "ago"
    
    duration = Time.now - time
    
    if duration < 0
      suffix = "left"
      duration = -duration
    end
   
   if duration >= 0 and duration < 60
     if duration.to_f.round == 0 or duration.to_f.round == 1
        semantic_time = duration.to_f.round.to_s + " second " + suffix
      else
        semantic_time = duration.to_f.round.to_s + " seconds " + suffix
      end
      
    elsif duration >= 60 and duration < (60 * 60)
      if (duration / 60).to_f.round == 1
        semantic_time = (duration / 60).to_f.round.to_s + " minute " + suffix
      else
        semantic_time = (duration / 60).to_f.round.to_s + " minutes " + suffix
      end
    elsif duration >= (60 * 60) and duration < (60 * 60 * 24)
      if (duration / (60 * 60)).to_f.round == 1
        semantic_time = (duration / (60 * 60)).to_f.round.to_s + " hour " + suffix
      else
        semantic_time = (duration / (60 * 60)).to_f.round.to_s + " hours " + suffix
      end
    elsif duration >= (60 * 60 * 24) and duration < (60 * 60 * 24 * 30)
      if (duration / (60 * 60 * 24)).to_f.round == 1
        semantic_time = (duration / (60 * 60 * 24)).to_f.round.to_s + " day " + suffix
      else
        semantic_time = (duration / (60 * 60 * 24)).to_f.round.to_s + " days " + suffix
      end
    elsif duration >= (60 * 60 * 24 * 30) and duration < (60 * 60 * 24 * 30 * 12)
      if (duration / (60 * 60 * 24 * 30)).to_f.round == 1
        semantic_time = (duration / (60 * 60 * 24 * 30)).to_f.round.to_s + " month " + suffix
      else
        semantic_time = (duration / (60 * 60 * 24 * 30)).to_f.round.to_s + " months " + suffix
      end
    elsif duration >= (60 * 60 * 24 * 30 * 12)
      if (duration / (60 * 60 * 24 * 30 * 12)).to_f.round == 1
        semantic_time = (duration / (60 * 60 * 24 * 30 * 12)).to_f.round.to_s + " year " + suffix
      else
        semantic_time = (duration / (60 * 60 * 24 * 30 * 12)).to_f.round.to_s + " years " + suffix
      end
    end
      
    return semantic_time
  end
  
  def wrap_word(word,char_width)
    return_string = ""
    word_list = word.split(/[ \t]+/)
    word_list.each do |word|
      if word.length > char_width
        loop_num = (word.length/char_width).ceil
        concat_list = []
        (0..loop_num).each do |i|
          concat_list.push(word[i*char_width,char_width])
        end
        return_string += concat_list.join(" ")
      else
        return_string += word + " "
      end
    end
    
    return_string = return_string.gsub(/(\n)/,'<br/>')
    
    return return_string
  end
  
  def trim_text(word,char_width,max_char)
    
    return_string = ""
    
    if word.length > max_char
      return_string = word[0,max_char]
    else
      return_string = word
    end
    
    return_string = wrap_word(return_string,char_width)
  
    return return_string
  end
  
  def format_error(error_obj)
    
    errors = {}
    
    error_obj.each { |attr,err_msg|
      if !errors[attr]
        errors[attr] = [err_msg]
      else
        errors[attr].push(err_msg)
      end
    }
    
    return errors
  end
end