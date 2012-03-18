# encoding: utf-8
require 'spec_helper'

describe 'KratooController' do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include LoginRspecHelper
  include FacebookConnectRspecHelper
  
  before(:each) do
    @member = mock_member("Tanin","AAA")
    commit_database
  end
  
  it "adds successfully (test add tags, delete tags, and normal login)" do 
    
    goto '/kratoo'
    
    fill 'kratoo_title', 'อั้มน่ารัก'
    fill 'kratoo_content',  "Test Content"
    
    fill 'search_tag', "พัชราภา\n"
    fill 'search_tag', "ฟิล์ม\n"
    
    html("kratoo_tags").should include("พัชราภา")
    html("kratoo_tags").should include("ฟิล์ม")
    
    click_object(element(:id=>"kratoo_tags").spans[1].a)
    
    wait_until { !html("kratoo_tags").include?("ฟิล์ม") }
    
    expect_html_to_include("kratoo_submit_panel_require_login",word_for("kratoo/_new_general.html.erb",:please_login))
    kratoo_login("Tanin","AAA")

    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
  end
  
  it "login failed (server-side)" do 
    
    goto '/kratoo'
    expect_html_to_include("kratoo_submit_panel_require_login",word_for("kratoo/_new_general.html.erb",:please_login))
    
    kratoo_login("Tanin","AAAB")
    expect_html_to_include("kratoo_login_error_panel",word_for(:login,:invalid))
    
  end
  
  it "login failed (client-side)" do 

    goto '/kratoo'
    expect_html_to_include("kratoo_submit_panel_require_login",word_for("kratoo/_new_general.html.erb",:please_login))
    
    kratoo_login("","")
    expect_html_to_include("kratoo_login_error_panel",word_for(:login,:username_presence))
    expect_html_to_include("kratoo_login_error_panel",word_for(:login,:password_presence)) 
    
  end
  
  it "adds successfully (test add tags and facebook login)" do
    
    member = mock_member("funk_pat","AAA","100002087059781")
    commit_database
    
    goto '/kratoo'
    
    fill 'kratoo_title',"อั้มน่ารัก"
    fill 'kratoo_content', "Test Content"
    
    fill 'search_tag', "พัชราภา\n"
    fill 'search_tag', "ฟิล์ม\n"

    expect_html_to_include("kratoo_tags","พัชราภา")
    expect_html_to_include("kratoo_tags","ฟิล์ม")
    
    click 'kratoo_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("tanin@nanakorn.com","ninatninat47")
      expect_path_to_be '/facebook_registration/receiver/kratoo'
      clear_facebook_cookies
      close_window
    end

    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
  end

  it "adds failed (Client side)" do 

    goto '/kratoo'
    
    fill 'kratoo_title', 'อั้มน่ารัก'
    fill 'kratoo_title', ''
    expect_html_to_include("kratoo_title_error_panel",word_for(:kratoo,:title_presence))
    
    long_content = ""
    300.times { long_content << 'a' }
    fill 'kratoo_title', long_content
    expect_html_to_include("kratoo_title_error_panel",word_for(:kratoo,:title_max_length))

    fill 'kratoo_content', "Test Content"
    fill 'kratoo_content', ""
        
    kratoo_login("Tanin","AAA")

    click 'kratoo_submit_button'
    expect_html_to_include("kratoo_error_panel",word_for(:kratoo,:title_max_length))
    expect_html_to_include("kratoo_error_panel",word_for(:kratoo,:content_presence))
    
  end

  it "adds failed (Server side)", :js => true do 

    goto '/kratoo'
    execute_script("kratoo_validator.validate_all = function() {return true;}");
        
    fill 'kratoo_title', ''
    
    long_content = ""
    256.times { long_content << 'a' }
    fill 'kratoo_title', long_content

    fill 'kratoo_content', "Test Content"
    fill 'kratoo_content', ""
        
    kratoo_login("Tanin","AAA")

    click 'kratoo_submit_button'
    
    expect_html_to_include("kratoo_error_panel",word_for(:kratoo,:title_max_length))
    expect_html_to_include("kratoo_error_panel",word_for(:kratoo,:content_presence))
    
  end
  
  it "adds successfully (anonymous facebook)" do
    
    member = mock_member("funk_pat","AAA","100002087059781")
    commit_database
    
    goto '/kratoo'
    
    fill 'kratoo_title',"อั้มน่ารัก"
    fill 'kratoo_content', "Test Content"
    
    fill 'search_tag', "พัชราภา\n"
    fill 'search_tag', "ฟิล์ม\n"

    expect_html_to_include("kratoo_tags","พัชราภา")
    expect_html_to_include("kratoo_tags","ฟิล์ม")
    
    click 'kratoo_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("tanin@nanakorn.com","ninatninat47")
      expect_path_to_be '/facebook_registration/receiver/kratoo'
      clear_facebook_cookies
      close_window
    end
 
    click 'kratoo_use_anonymous_name_button'
    
    fill 'kratoo_username', "TaninAnonymous"

    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
    expect_html_to_include("kratoo_creator","TaninAnonymous")
    
  end
  
  it "adds successfully (anonymous login)" do
    
    goto '/kratoo'
    
    fill 'kratoo_title',"อั้มน่ารัก"
    fill 'kratoo_content', "Test Content"
    
    fill 'search_tag', "พัชราภา\n"
    fill 'search_tag', "ฟิล์ม\n"

    expect_html_to_include("kratoo_tags","พัชราภา")
    expect_html_to_include("kratoo_tags","ฟิล์ม")
    
    kratoo_login("Tanin","AAA")
 
    click 'kratoo_use_anonymous_name_button'
    
    fill 'kratoo_username', "TaninAnonymous"

    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
    expect_html_to_include("kratoo_creator","TaninAnonymous")
    
  end
  
  it "adds successfully (anonymous then change to real username)" do
    
    member = mock_member("funk_pat","AAA","100002087059781")
    commit_database
    
    goto '/kratoo'
    
    fill 'kratoo_title',"อั้มน่ารัก"
    fill 'kratoo_content', "Test Content"
    
    fill 'search_tag', "พัชราภา\n"
    fill 'search_tag', "ฟิล์ม\n"

    expect_html_to_include("kratoo_tags","พัชราภา")
    expect_html_to_include("kratoo_tags","ฟิล์ม")
    
    click 'kratoo_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("tanin@nanakorn.com","ninatninat47")
      expect_path_to_be '/facebook_registration/receiver/kratoo'
      clear_facebook_cookies
      close_window
    end
 
    click 'kratoo_use_anonymous_name_button'
    
    fill 'kratoo_username', "TaninAnonymous"
    
    click 'kratoo_use_real_name_button'

    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
    expect_html_to_include("kratoo_creator","funk_pat")
    
  end
  
  
end