require 'watir-webdriver'
require File.expand_path("../../base/firebug", __FILE__)
require File.expand_path("../../base/browser", __FILE__)

class TestBrowser
  
  
  def initialize
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.enable_firebug
    driver = Selenium::WebDriver.for(:firefox, { :profile => profile })
    
    @browser = Watir::Browser.new(driver)
  end
  
  def browser
    @browser
  end
  
  include Browser
end

browser = TestBrowser.new
browser.goto "file://" + File.expand_path("../button.html", __FILE__)
#browser.goto "http://localhost:3000/kratoo"

browser.fill 'kratoo_login_username', "username"
browser.fill 'kratoo_login_password', "password"

id = "kratoo_login_button"

100.times { 
  browser.click id
  sleep(1)
  puts browser.execute_script "return window.YesItWork;"
  browser.execute_script "window.YesItWork = '-';"
}



#browser.element(:id=>"test_input_button").focus
#browser.element(:id=>"test_input_button").click

#puts browser.element(:id=>"test_button").text
#browser.element(:id=>"test_button").fire_event("onclick")