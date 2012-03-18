require 'watir-webdriver'
require File.expand_path("../firebug", __FILE__)
require File.expand_path("../browser", __FILE__)

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
browser.goto "file://#{File.expand_path("../index.html", __FILE__)}"

browser.element(:id=>"anchor_button_send_key").focus
browser.element(:id=>"anchor_button_send_key").send_keys("\n")

browser.element(:id=>"span_button_send_key").focus
browser.element(:id=>"span_button_send_key").send_keys("\n")

browser.element(:id=>"button_button_send_key").focus
browser.element(:id=>"button_button_send_key").send_keys("\n")

browser.element(:id=>"input_button_send_key").focus
browser.element(:id=>"input_button_send_key").send_keys("\n")


browser.element(:id=>"anchor_button_click").click
browser.element(:id=>"span_button_click").click
browser.element(:id=>"button_button_click").click
browser.element(:id=>"input_button_click").click

puts browser.element(:id=>"test_html").html
puts browser.element(:id=>"test_html").text
puts browser.html("test_html")