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

test = TestBrowser.new
test.goto "file://" + File.expand_path("../index.html", __FILE__)

test.fill("editor", "Aaaaa")
test.element(:id=>"editor_toolbar").element(:class=>"image_button").click

test.upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../test_upload_picture.jpg", __FILE__))
                  
test.upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../test_upload_picture.jpg", __FILE__))
                  
test.element(:id=>"writepub_editor_thumbnail_unit_0").click
test.element(:id=>"writepub_editor_thumbnail_unit_1").click
test.element(:id=>"writepub_editor_insert_image_button").click

test.fill("test_text", "aaa")