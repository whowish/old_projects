# encoding: utf-8
require 'watir-webdriver'

class Selenium::WebDriver::Firefox::Profile
  def self.firebug_version
    @firebug_version ||= '1.7.3'
  end

  def self.firebug_version=(version)
    @firebug_version = version
  end

  def enable_firebug(version = nil)
    version ||= Selenium::WebDriver::Firefox::Profile.firebug_version
    add_extension(File.expand_path("../firebug-#{version}.xpi", __FILE__))

    # Prevent "Welcome!" tab
    self["extensions.firebug.currentVersion"] = "999"

    # Enable for all sites.
    self["extensions.firebug.allPagesActivation"] = "on"

    # Enable all features.
    ['console', 'net', 'script'].each do |feature|
      self["extensions.firebug.#{feature}.enableSites"] = true
    end

    # Closed by default.
    self["extensions.firebug.previousPlacement"] = 2
  end
end

profile = Selenium::WebDriver::Firefox::Profile.new
profile.enable_firebug
driver = Selenium::WebDriver.for(:firefox, { :profile => profile })

b = Watir::Browser.new(driver)
b.goto "file://C:/Users/Tanin/Documents/Ruby/writepub/public/turquoise/index.html"

puts b.url

b.element(:id=>"open_dialog").click
100.times { b.element(:id=>"count_button").click }

b.text_field(:id=>"test_blur").set "Hello"
b.text_field(:id=>"test_blur").fire_event("onblur")

puts b.execute_script("document.location.toString();")