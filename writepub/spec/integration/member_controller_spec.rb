# encoding: utf-8
require 'spec_helper'

describe 'MemberController' do
  
  include MemberRspecHelper
  
  before(:each) do
    @member = mock_member("Tanin","AAA")
  end
 
  it "logins successfully (top-right)" do
    
    goto "/kratoo"
    click 'top_right_login_bubble_button'
    
    fill 'top_right_login_username', "Tanin"
    fill 'top_right_login_password', "AAA"
    
    click 'top_right_login_submit_button'
    expect_path_to_be '/kratoo'
    
  end
  
  it "logins failed (Server side, top-right)" do
    
    goto "/kratoo"
    click 'top_right_login_bubble_button'
    
    fill 'top_right_login_username', "Tanin"
    fill 'top_right_login_password', "AAAB"
    
    click 'top_right_login_submit_button'
    expect_html_to_include('top_right_login_error_panel',word_for(:login,:invalid))
    
  end
  
  it "logins failed (client side, top-right)" do
    
    goto "/kratoo"
    click 'top_right_login_bubble_button'
    
    fill 'top_right_login_username', ""
    fill 'top_right_login_password', ""
    
    click 'top_right_login_submit_button'
    
    expect_html_to_include('top_right_login_error_panel',word_for(:login,:username_presence))
    expect_html_to_include('top_right_login_error_panel',word_for(:login,:password_presence))
    
  end
  
  it "logins successfully " do
  
    goto "/member/login_form?redirect_url=#{CGI.escape('/kratoo')}"
    
    fill "login_form_username", "Tanin"
    
    fill 'login_form_password', "AAA"
    
    click 'login_form_submit_button'
    expect_path_to_be '/kratoo'
    
  end
  
  it "logins failed (Server side)" do
    
    goto "/member/login_form?redirect_url=#{CGI.escape('/kratoo')}"

    fill 'login_form_username', "Tanin"
    fill 'login_form_password', "AAAB"
    
    click 'login_form_submit_button'
    expect_html_to_include('login_form_error_panel',word_for(:login,:invalid))
    
  end
  
  it "logins failed (client side)" do
    
    goto "/member/login_form?redirect_url=#{CGI.escape('/kratoo')}"
    
    fill 'login_form_username', ""
    fill 'login_form_password', ""
    
    click 'login_form_submit_button'
    
    expect_html_to_include('login_form_error_panel', word_for(:login,:username_presence))
    expect_html_to_include('login_form_error_panel', word_for(:login,:password_presence))
    
  end
end