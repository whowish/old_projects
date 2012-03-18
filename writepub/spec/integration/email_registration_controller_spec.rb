# encoding: utf-8
require 'spec_helper'

module EmailRegistrationRspecHelper
  def try_register_email(email)
    goto_register_email
    fill_register_email(email)
  end
  
  def goto_register_email
    goto "/member"
  end
  
  def fill_register_email(email)
    fill "email_registration_email", email
    click "email_registration_submit_button"
  end
  
  def try_confirm_email(email_pending,username,password)
    goto_confirm_email(email_pending)
    fill_confirm_email(username,password)
  end
  
  def goto_confirm_email(email_pending)
    goto "/email_registration?email=#{CGI.escape(email_pending.email)}&unique_key=#{email_pending._id}"
  end
  
  def fill_confirm_email(username,password)
    fill "email_registration_username", username
    fill "email_registration_password", password
    click "email_registration_submit_button"
  end
end

describe 'EmailRegistrationController' do
  
  include EmailRegistrationRspecHelper
  
  it "registers email, then register username/password, and automatically logins" do

    try_register_email("aniknun@nanakorn.com")
    wait_until { current_path == '/email_registration/please_check_your_email' }
    
    expect_and_perform_queue(:normal,1)
    
    email_pending = EmailRegistrationPending.where(:email=>"aniknun@nanakorn.com").first
    email_pending.should_not be_nil
    
    try_confirm_email(email_pending,"aniknun","pass")
    wait_until { current_path == "/email_registration/thank_you" }
    
  end
  
  it "shows invalid page, when there is no record of EmailRegistrationPending" do
    
    goto "/email_registration?email=xxx@sss.com&unique_key=aaa"
    exists?(:id=>"email_registration_submit_button").should be_false
    
  end
  
  it "registers username/password, but that email is already registered, therefore, the error message is shown." do
    
    try_register_email("aniknun@nanakorn.com")
    wait_until { current_path == '/email_registration/please_check_your_email' }
    
    expect_and_perform_queue(:normal,1)
    
    email_pending = EmailRegistrationPending.where(:email=>"aniknun@nanakorn.com").first
    email_pending.should_not be_nil
    
    goto_confirm_email(email_pending)
 
    # mock member with the same email
    member = Member.create(:username=>"funk_pat",:email=>email_pending.email)
    commit_database
    
    fill_confirm_email("aniknun","pass")
    wait_until { html("email_registration_error_panel").include?(word_for(:member,:email_uniqueness)) }
    
  end
  
  it "ensures email uniqueness on registering email" do
    
    member = Member.create(:username=>"funk_pat",:email=>"aniknun@nanakorn.com")
    commit_database
    
    try_register_email("aniknun@nanakorn.com")
    wait_until { html("email_registration_error_panel").include?(word_for(:member,:email_uniqueness)) }
    
  end
  
  it "ensures username uniqueness on registering username/password" do

    member = Member.create(:username=>"funk_pat",:email=>"some@some.com")
    email_pending = EmailRegistrationPending.create(:email=>"aniknun@nanakorn.com",:_id=>"AAAA")
    commit_database
    
    try_confirm_email(email_pending,"funk_pat","pass")
    wait_until { html("email_registration_error_panel").include?(word_for(:member,:username_uniqueness)) }
  end
  
  it "does server-side validation on registering email (presence)" do

    goto_register_email
    execute_script("email_registration_validator.validate_all = function() {return true;}");
    
    fill_register_email("")
    wait_until { html("email_registration_error_panel").include?(word_for(:email_registration,:email_presence)) }
    
  end
  
  it "does server-side validation on registering email (email format)" do

    goto_register_email
    execute_script("email_registration_validator.validate_all = function() {return true;}");
    
    fill_register_email("afeqgqgqwf")
    wait_until { html("email_registration_error_panel").include?(word_for(:email_registration,:email_email)) }
    
  end
  
  it "does client-side validation on registering email (presence)" do
    try_register_email("")
    wait_until { html("email_registration_error_panel").include?(word_for(:email_registration,:email_presence)) }
  end
  
  it "does client-side validation on registering email (email format)" do 
    try_register_email("asasfafsa")
    wait_until {  html("email_registration_error_panel").should include(word_for(:email_registration,:email_email)) }
  end
  
  it "does server-side validation on registering username/password" do

    email_pending = EmailRegistrationPending.create(:email=>"aniknun@nanakorn.com",:_id=>"AAAA")
    commit_database
    
    goto_confirm_email(email_pending)
    execute_script("email_registration_validator.validate_all = function() {return true;}");
    
    fill_confirm_email("", "")
    
    wait_until {  html("email_registration_username_error_panel").include?(word_for(:member,:username_presence)) }
    wait_until {  html("email_registration_password_error_panel").include?(word_for(:member,:password_presence)) }
    
    wait_until {  html("email_registration_error_panel").include?(word_for(:member,:username_presence)) }
    wait_until {  html("email_registration_error_panel").include?(word_for(:member,:password_presence)) }
    
  end
  
  it "does client-side validation on registering username/password" do
    
    email_pending = EmailRegistrationPending.create(:email=>"aniknun@nanakorn.com",:_id=>"AAAA")
    commit_database
    
    try_confirm_email(email_pending,"", "")
    
    html("email_registration_username_error_panel").should include(word_for(:member,:username_presence))
    html("email_registration_password_error_panel").should include(word_for(:member,:password_presence))
    
    html("email_registration_error_panel").should include(word_for(:member,:username_presence))
    html("email_registration_error_panel").should include(word_for(:member,:password_presence))
  end
end