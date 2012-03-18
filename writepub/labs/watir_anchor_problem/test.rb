# encoding: utf-8
require 'watir-webdriver'
require File.expand_path("../lib", __FILE__)


profile = Selenium::WebDriver::Firefox::Profile.new
profile.enable_firebug
driver = Selenium::WebDriver.for(:firefox, { :profile => profile })

browser = Watir::Browser.new(driver)
browser.goto "file://C:/Users/Tanin/Documents/Ruby/writepub/labs/watir_anchor_problem/index.html"


100.times { |i|
  puts i
  puts browser.execute_script("return document.location.toString();")
  puts browser.url
  browser.element(:id=>"open_dialog_button_with_span").focus
  browser.element(:id=>"open_dialog_button_with_span").send_keys "\n"
  puts browser.element(:id=>"open_dialog").tag_name
  sleep(1)
  browser.element(:class=>"ui-dialog-titlebar-close").focus
  browser.element(:class=>"ui-dialog-titlebar-close").send_keys "\n"
  browser.element(:class=>"ui-dialog-titlebar-close").wait_while_present
  sleep(1)
  
}