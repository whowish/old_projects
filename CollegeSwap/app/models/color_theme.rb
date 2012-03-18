class ColorTheme
  attr_accessor :bgColor,:buttonColor,:textColor,:bgColorCode
  def initialize()
    @bgColor = "" 
    @buttonColor = ""
    @textColor = ""
    @bgColorCode = ""
  end
  
  def self.get_blue()
    return_color = ColorTheme.new
    return_color.bgColor = "light_blue_bg"
    return_color.buttonColor = "dark_blue_bg"
    return_color.textColor = "medium_dark_blue"
    return_color.bgColorCode = "#1963BD"
    return return_color
  end
  
  def self.get_green()
    return_color = ColorTheme.new
    return_color.bgColor = "light_green_bg"
    return_color.buttonColor = "whowish_green_bg"
    return_color.textColor = "medium_dark_green"
    return_color.bgColorCode = "#78BD40"
    return return_color
  end
end