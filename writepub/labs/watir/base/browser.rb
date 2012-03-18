# encoding: utf-8
require 'uri'
module Browser
  
  def goto(url)
    browser.goto(url)
    browser.wait(120)
    wait_for_ajax
    browser.execute_script("window.alert = function(msg) { window.lastAlert = msg; }")
  end
  
  def expect_alert(msg)
    wait_until { browser.execute_script("return window.lastAlert") == msg }
  end
  
  def click(id)
    click_object(element(:id=>id))
  end
  
  def element(*option)
    browser.element(*option)
  end
  
  def click_object(obj)
    
    inner_click(obj)
    
    browser.wait(120)
    wait_for_ajax
  end
  
  def inner_click(obj)
    
    position = browser.execute_script "return $('##{obj.id}').css('position');"
    left = browser.execute_script "return $('##{obj.id}').css('left');"
    top = browser.execute_script "return $('##{obj.id}').css('top');"
    
    browser.execute_script "$('##{obj.id}').css({position:'fixed',left:'0px',top:'0px'});"

    obj.focus
    
    if ["a","button"].include?(obj.tag_name.downcase)
      obj.send_keys "\n"
    else
      obj.click
    end
    
    browser.execute_script "$('##{obj.id}').css({position:'#{position}',left:'#{left}',top:'#{top}'});"
  end
  
  def fill(id,msg)
    
    elem = browser.element(:id=>id)
    
    if elem.tag_name.downcase == "iframe"
      elem.focus
      elem.send_keys msg
      elem.fire_event('onblur')
    else
      browser.text_field(:id=>id).focus
      browser.text_field(:id=>id).set msg
      browser.text_field(:id=>id).fire_event('onblur')
    end
    

  end
  
  def upload_file(id, file_field_id, file_path)
    browser.element(:id=>id).fire_event("onmouseover")
    fill(file_field_id, file_path.gsub("/","\\"))
    wait_for_ajax
  end
  
  def value(id)
    browser.element(:id=>id).value
  end
  
  def html(id)
    browser.execute_script("return document.getElementById('#{id}').innerHTML")
  end
  
  def expect_html_to_include(id,content)
    begin
      wait_until {
        b = browser.element(:id=>id)
        b.exist? && b.html.include?(content) 
      }
    rescue Watir::Wait::TimeoutError => e
      raise Watir::Wait::TimeoutError, "Content is expected to include '#{content}', instead we got '#{html(id)}'"
    end
  end
  
  
  def current_path
    URI.parse(browser.execute_script("return document.location.toString();")).path.chomp('/')
  end
  
  def current_host
    URI.parse(browser.execute_script("return document.location.toString();")).host.chomp('/')
  end
  
  def use_window_if_visible(part_of_url_regexp,&block)
    
    begin
      use_window(part_of_url_regexp,&block)
    rescue Watir::Exception::NoMatchingWindowFoundException => e
      # ignore it
    end
  end
  
  def use_window(part_of_url_regexp,&block)
    
    timeout = 10
    count = 0
    while true
    
      begin
        browser.window(:url => part_of_url_regexp).use(&block)
        break
      rescue Watir::Exception::NoMatchingWindowFoundException => e
        sleep(1)
        count += 1
        raise e if count > timeout
      end
      
    end
    
  end
  
  def wait_until_present(id)
    browser.element(:id=>id).wait_until_present
  end
  
  def wait_while_present(id)
    browser.element(:id=>id).wait_while_present
  end
  
  def wait_until(&block)
    browser.wait_until(&block)
  end
  
  def expect_path_to_be(path)

    begin
      if path.instance_of?(Regexp)
        wait_until { current_path.match(path) != nil }
      else
        path = path.chomp('/')
        wait_until { current_path == path }
      end
    rescue Watir::Wait::TimeoutError => e
      raise Watir::Wait::TimeoutError, "Path is expected to be '#{path}', instead we got '#{current_path}'"
    end
    
  end
  
  def exists?(*option)
    browser.element(*option).exists?
  end
  
  def execute_script(js)
    browser.execute_script(js)
  end
  
  def wait_for_ajax
    begin
      wait_until { browser.execute_script "return jQuery.active == 0" }
    rescue Selenium::WebDriver::Error::UnexpectedJavascriptError
      # do nothing
    rescue Watir::Wait::TimeoutError => e
      raise Watir::Wait::TimeoutError, "Ajax is taking too long"
    end
  end
  
end