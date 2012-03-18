# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ThumbnailismHelper
  include FacebookHelper
  include Foundation
  include ActionView::Helpers::NumberHelper
  
  def get_place_of(facebook_id)
    member = Member.first(:conditions=>{:facebook_id=>facebook_id})
    
    return nil if !member
    
    college = College.first(:conditions=>{:id=>member.college_id});
    
    return nil if !college
    return nil if !college.place_name or college.place_name == ""
    
    return {:name=>college.place_name,:address=>college.place_address}
  end
  
  def get_college_name(college_id)
    college = College.first(:conditions=>{:id=>college_id});
    
    return "" if !college
    return college.name
  end
  
  def get_college_name_of(facebook_id)
    member = Member.first(:conditions=>{:facebook_id=>facebook_id})
    
    return "" if !member
    
    return get_college_name(member.college_id)
  end

  
  def trim_title(word,char_width,max_char)
    return_string = ""
    trim_string = ""
    trim_string = trim_text(word,char_width,max_char)
    
    trim_string_by_line = trim_string.split('<br/>')
    return_string = trim_string_by_line[0]
  
    if is_read_more(word,max_char,1,trim_string_by_line.length)
      return_string += "..."
    end
    
    return return_string
  end
 
  def trim_description(item_id,word,char_width,max_char,max_line=0)
    return_string = ""
    trim_string = ""
    trim_string = trim_text(word,char_width,max_char)
    
    trim_string_by_line = trim_string.split('<br/>')
    
    return_string = trim_string 
    if max_line > 0
        return_string = trim_string_by_line[0...max_line].join('<br/>')
    end
    
    if is_read_more(word,max_char,max_line,trim_string_by_line.length)
     
      return_string += "<a href='#' class='dark_gray' onclick='$.whowish_box({title: \"View\",url:\"/item/view?item_id="+item_id.to_s+"\"}); return false;'> (read more)</a>"
    end
    
    return return_string

  end

  def is_read_more(word,max_char,max_line,all_line)
    if word.length > max_char 
      return true
    end 
    if all_line > max_line
      return true
    end
    return false
  end
  
  def get_color_theme(item)
    c = ColorTheme.get_blue
    c = ColorTheme.get_green if item.item_type == Item::ITEM_TYPE_WISH and $facebook.facebook_id == item.facebook_id
    c = ColorTheme.get_green if item.item_type == Item::ITEM_TYPE_JUNK and $facebook.facebook_id != item.facebook_id
    c.textColor = "gold" if item.is_money == 1
    
    return c
    
  end
  
  def keyword_match(a,b)

    w_a = a.downcase.split(/[\s]+/)
    w_b = b.downcase.split(/[\s]+/)
    
    return (w_a&w_b).length > 0
  end
  
  def format_currency_by_country_code(country_code,number)
    currency = Currency.get_by_country_code(country_code)
    return number_to_currency(number, :unit => currency.sign, :separator => currency.separator, :delimiter => currency.delimiter, :format => currency.format)
  end
  
  def format_currency_by_currency_code(currency_code,number)
    currency = Currency.get_by_currency_code(currency_code)
    return number_to_currency(number, :unit => currency.sign, :separator => currency.separator, :delimiter => currency.delimiter, :format => currency.format)
  end
 
end
