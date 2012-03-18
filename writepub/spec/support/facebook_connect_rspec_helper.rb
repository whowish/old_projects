# encoding: utf-8
module FacebookConnectRspecHelper
  include DebuggerHelper
  
  def facebook_connect(username,password)
    
    if current_path == "/login.php"
        fill 'email', username, false
        fill 'pass', password, false
        element(:name=>"login").click
    end
    
    browser.wait(120)
    wait_for_ajax
    
    if current_path == "/connect/uiserver.php" \
        or current_path == "/dialog/permissions.request"
       element(:name=>"grant_clicked").click
    end
   
  end
  
  def clear_facebook_cookies
    
    goto 'http://www.facebook.com'
    browser.clear_cookies
    
  end
end