# encoding: utf-8
require 'spec_helper'

module FacebookRegistrationRspecHelper
  
  def try_register_facebook
    goto '/member'
    click 'facebook_registration_button'
  end
  
  def try_register_facebook_on_top_right
    goto '/kratoo'
    click 'top_right_login_bubble_button'
    click 'top_right_facebook_login_button'
  end
  
  def fill_register_facebook(username,password)
    fill 'facebook_registration_username', username
    fill 'facebook_registration_password', password
    
    click 'facebook_registration_submit_button'
  end
end


describe 'FacebookRegistrationController' do
  include FacebookConnectRspecHelper
  include FacebookRegistrationRspecHelper

  before(:each) do
    @member = Member.create(:username=>"aniknun",:email=>"aniknun@nanakorn.com")
  end
  
  it "connects to facebook, successfully registers, and automatically logins" do 

    try_register_facebook
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration' 
    
    fill_register_facebook("tanin", "password")
    expect_path_to_be '/' 
    
    clear_facebook_cookies
  end
  
  it "connects to facebook, but user is already a member, so it logged in automatically" do 

    member = Member.create(:username=>"funk_pat",:facebook_id=>"100002087059781")
    commit_database
    
    try_register_facebook
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/' 
    
    clear_facebook_cookies
    
  end
  
  it "connects to facebook, show user the registration page, but user is already a member, therefore, it should show error message." do 
    
    try_register_facebook
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration' 
    
    member = Member.create(:username=>"funk_pat",:facebook_id=>"100002087059781")
    commit_database
    
    fill_register_facebook("tanin", "password")
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:facebook_id_uniqueness))
    
    clear_facebook_cookies
    
  end
  
  it "(Use top-right button) connects to facebook, successfully registers, and automatically logins" do 

    try_register_facebook_on_top_right
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration/kratoo' 
    
    fill_register_facebook("tanin", "password")
    expect_path_to_be '/kratoo' 
    
    clear_facebook_cookies
    
  end
  
  it "does server-side validation" do
    
    try_register_facebook_on_top_right
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration/kratoo'
    
    execute_script("facebook_registration_validator.validate_all = function() {return true;}");
    fill_register_facebook("", "")
    
    expect_html_to_include("facebook_registration_username_error_panel",word_for(:member,:username_presence))
    expect_html_to_include("facebook_registration_password_error_panel",word_for(:member,:password_presence))
    
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:username_presence))
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:password_presence)) 
    
    clear_facebook_cookies
    
  end
  
  it "validates username uniqueness" do
    
    try_register_facebook_on_top_right
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration/kratoo'
    
    fill_register_facebook("aniknun", "password")
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:username_uniqueness))
    
    clear_facebook_cookies
    
  end
  
  it "does client-side validation" do
    
    try_register_facebook_on_top_right
    facebook_connect("tanin@nanakorn.com","ninatninat47")
    expect_path_to_be '/facebook_registration/kratoo'
    
    fill_register_facebook("", "")
    
    expect_html_to_include("facebook_registration_username_error_panel",word_for(:member,:username_presence))
    expect_html_to_include("facebook_registration_password_error_panel",word_for(:member,:password_presence))
    
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:username_presence))
    expect_html_to_include("facebook_registration_error_panel",word_for(:member,:password_presence))
    
    clear_facebook_cookies
    
  end
end