# encoding: utf-8
require 'spec_helper'


describe 'ReplyController' do
  
  include KratooRspecHelper
  include ReplyRspecHelper
  include MemberRspecHelper
  include FacebookConnectRspecHelper
  
  before(:each) do
    
    @member = mock_member("Tanin","AAA","100002087059781")
    @kratoo = mock_kratoo(@member,"Title","Content")
    commit_database
    
  end
  
  it "adds successfully (normal login)" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("Tanin","AAA")

    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>@kratoo.id})
    expect_html_to_include("reply_#{reply.id}","test_content123")
    value("reply_content").should == ""
  end

  
  it "login failed (server-side)" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
        
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("Tanin","AAAB")
    expect_html_to_include("reply_login_error_panel",word_for(:login,:invalid))
    
  end
  
  it "login failed (client-side)", :js => true do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
    
    reply_login("","")
    
    expect_html_to_include("reply_login_error_panel",word_for(:login,:username_presence))
    expect_html_to_include("reply_login_error_panel",word_for(:login,:password_presence))
  
  end
  
  it "adds successfully (test add tags and facebook login)", :js => true do 

    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login", word_for("reply/_add.html.erb",:please_login))
    
    click 'reply_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("tanin@nanakorn.com","ninatninat47")
      expect_path_to_be "/facebook_registration/receiver/reply/#{@kratoo.id}"
      clear_facebook_cookies
      close_window
    end
    
    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>@kratoo.id})
    expect_html_to_include("reply_#{reply.id}","test_content123")
    value("reply_content").should == ""
    
  end

  it "adds failed (Client side)", :js => true do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "qeqfqf"
    fill 'reply_content', ""
    
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("Tanin","AAA")

    click 'reply_submit_button'
    expect_html_to_include("reply_error_panel",word_for(:reply,:content_presence))
    
  end

  it "adds failed (Server side)", :js => true do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    execute_script("reply_validator.validate_all = function() {return true;}");

    fill 'reply_content', ""
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("Tanin","AAA")

    click 'reply_submit_button'
    
    expect_html_to_include("reply_content_error_panel",word_for(:reply,:content_presence))
    expect_html_to_include("reply_error_panel",word_for(:reply,:content_presence))
    
  end
  
  it "adds successfully (anonymous)" do 
    member = mock_member("ni","AAA","100002085428291")
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    click 'reply_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("moopino@hotmail.com","asdfg588")
      expect_path_to_be "/facebook_registration/receiver/reply/#{@kratoo.id}"
      clear_facebook_cookies
      close_window
    end
    
    click 'reply_use_anonymous_name_button'
    
    fill 'reply_username', "NiAnonymous"
  
    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>@kratoo.id})
    expect_html_to_include("reply_#{reply.id}","test_content123")
    value("reply_content").should == ""
    
    expect_html_to_include("reply_creator_#{reply.id}","NiAnonymous")
    
  end
  
  it "adds successfully (anonymous then change to real name)" do 
    
    member = mock_member("ni","AAA","100002085428291")
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    click 'reply_facebook_login_button'
  
    use_window /facebook\.com/ do
      facebook_connect("moopino@hotmail.com","asdfg588")
      expect_path_to_be "/facebook_registration/receiver/reply/#{@kratoo.id}"
      clear_facebook_cookies
      close_window
    end
    
    click 'reply_use_anonymous_name_button'
    
    fill 'reply_username', "NiAnonymous"
    
     click 'reply_use_real_name_button'

    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>@kratoo.id})
    expect_html_to_include("reply_#{reply.id}","test_content123")
    value("reply_content").should == ""
    
    expect_html_to_include("reply_creator_#{reply.id}","ni")
    
  end
  
  it "reply to anonymous kratoo successfully" do 
    @anonymous_kratoo = mock_anonymous_kratoo(@member,"Title","Content")
    
    member = mock_member("ni","AAA","100002085428291")
    
    goto "/kratoo/view/#{@anonymous_kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("ni","AAA")
    
    
    click 'reply_use_anonymous_name_button'
    
    fill 'reply_username', "NiAnonymous"
  
    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>@anonymous_kratoo.id})
    expect_html_to_include("reply_#{reply.id}","test_content123")
    value("reply_content").should == ""
    
    expect_html_to_include("reply_creator_#{reply.id}","NiAnonymous")
    expect_html_to_include("comment_panel","reply_anonymous_name_panel")
    
  end
  
  it "reply to anonymous kratoo not successfully (same anonymous name)" do 
    @anonymous_kratoo = mock_anonymous_kratoo(@member,"Title","Content")
    
    @anonymous_kratoo.is_used_anonymous_name("Tanin_anonymous").should == true
    
    member = mock_member("ni","AAA","100002085428291")
    
    goto "/kratoo/view/#{@anonymous_kratoo.id}"
    
    fill 'reply_content', "test_content123"
    expect_html_to_include("reply_submit_panel_require_login",word_for("reply/_add.html.erb",:please_login))
        
    reply_login("ni","AAA")
    
    
    click 'reply_use_anonymous_name_button'
    
    fill 'reply_username', "Tanin_anonymous"
  
    click 'reply_submit_button'
    expect_html_to_include("reply_error_panel",word_for(:kratoo,:username_redundant))
    
  end
  
end