# encoding: utf-8

class Selenium::WebDriver::Firefox::Profile
  def self.firebug_version
    @firebug_version ||= '1.7.3'
  end

  def self.firebug_version=(version)
    @firebug_version = version
  end

  def enable_firebug(version = nil)
    version ||= Selenium::WebDriver::Firefox::Profile.firebug_version
    
    
    add_extension(File.expand_path("../firebug-1.8.1.xpi", __FILE__))
    #add_extension(File.expand_path("../firebug-1.7.3.xpi", __FILE__))

    # Prevent "Welcome!" tab
    self["extensions.firebug.currentVersion"] = "999"

    # Enable for all sites.
    self["extensions.firebug.allPagesActivation"] = "on"

    # Enable all features.
    ['console', 'net', 'script'].each do |feature|
      self["extensions.firebug.#{feature}.enableSites"] = true
    end

    # Closed by default.
    self["extensions.firebug.previousPlacement"] = 3
  end
end