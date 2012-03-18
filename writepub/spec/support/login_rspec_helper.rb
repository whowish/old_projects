# encoding: utf-8
module LoginRspecHelper
  def top_right_login(username,password)
    click 'top_right_login_bubble_button'
    
    fill 'top_right_login_username', username
    fill 'top_right_login_password', password
    
    click 'top_right_login_submit_button'
  end
  
  def logout
    click 'logout_button'
  end
end