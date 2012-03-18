# encoding: utf-8
require 'spec_helper'

module ReplyOfReplyRspecHelper
  
  def login(username,password)
    browser.text_field(:id=>'reply_of_reply_login_username').set username
    browser.text_field(:id=>'reply_of_reply_login_password').set password
    browser.span(:id=>'reply_of_reply_login_button').click
  end
  
  def validate_ror_content(content)
    ror = ReplyOfReply.first(:conditions=>{:reply_id=>@reply.id})

    html("reply_of_reply_#{ror.id}").should include(content)
    value("reply_of_reply_content").should == ""
  end
  
  def ror_facebook_connect(username,password)
    click "reply_of_reply_facebook_login_button"
    use_window(/facebook\.com/) {
      facebook_connect(username,password)
      current_path.should == "/facebook_registration/receiver/reply/#{@kratoo.id}"
      clear_facebook_cookies
      close_window
    }
  end
  
end

describe 'ReplyOfReplyController' do
  
  include LoginRspecHelper
  include FacebookConnectRspecHelper
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  
  before(:each) do
    
    @member = mock_member("Tanin", "AAA", "100002087059781")
    @kratoo = mock_kratoo(@member, "Title", "content")
    @reply = mock_reply(@member, @kratoo, "content")
    commit_database
    
  end
  


  it "replies successfully (normal login)" do 
 
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("Tanin","AAA")
    submit_ror_content("some content")
    validate_ror_content("some content")

  end
  
  it "replies successfully (facebook login)" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    ror_facebook_connect("tanin@nanakorn.com","ninatninat47")
    submit_ror_content("some content")
    validate_ror_content("some content")
    
  end
 
  it "login failed (server-side)" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("Tanin","AAAB")
    
    expect_html_to_include("reply_of_reply_login_error_panel", word_for(:login,:invalid))
    
  end
  
  it "login failed (client-side)", :js => true do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("","")
    
    expect_html_to_include("reply_of_reply_login_error_panel", word_for(:login,:username_presence))
    expect_html_to_include("reply_of_reply_login_error_panel", word_for(:login,:password_presence))
  
  end


  it "adds failed (Client side)", :js => true do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("Tanin","AAA")
    
    wait_until_present "reply_of_reply_content"
    
    fill "reply_of_reply_content", "qeqfqf"
    fill "reply_of_reply_content", ""

    click 'reply_of_reply_submit_button'
    html("reply_of_reply_error_panel").should include(word_for(:reply_of_reply,:content_presence))
    
  end


  it "adds failed (Server side)" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("Tanin","AAA")
    
    wait_until_present "reply_of_reply_content"
    
    # because we want to bypass client validation and test server validation
    browser.execute_script("reply_of_reply_validator.validate_all = function() {return true;}");

    fill "reply_of_reply_content", ""
    click 'reply_of_reply_submit_button'
    
    wait_until { 
      html("reply_of_reply_content_error_panel").include?(word_for(:reply_of_reply,:content_presence))
    }
    
    html("reply_of_reply_content_error_panel").should include(word_for(:reply_of_reply,:content_presence))
    html("reply_of_reply_error_panel").should include(word_for(:reply_of_reply,:content_presence))

end

it "replies successfully (anonymous)" do 
    member = mock_member("ni","AAA","100002085428291")
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("ni","AAA")
    
    wait_until_present 'reply_of_reply_content'
    fill 'reply_of_reply_content', "some content"
    
    click 'ror_use_anonymous_name_button'
    
    fill 'reply_of_reply_username', "NiAnonymous"
    
    
    click 'reply_of_reply_submit_button'
    wait_while_present 'reply_of_reply_submit_button'

    commit_database
    
    validate_ror_content("some content")
    
    ror = ReplyOfReply.first(:conditions=>{:reply_id=>@reply.id})
    expect_html_to_include("reply_of_reply_content_#{ror.id}","NiAnonymous")
    
  end
  
  it "adds successfully (anonymous then change to real name)" do 
    
    member = mock_member("ni","AAA","100002085428291")
    goto "/kratoo/view/#{@kratoo.id}"
    
    open_ror_dialog(@reply)
    login("ni","AAA")
    
    wait_until_present 'reply_of_reply_content'
    fill 'reply_of_reply_content', "some content"
    
    click 'ror_use_anonymous_name_button'
    
    fill 'reply_of_reply_username', "NiAnonymous"
   
    click 'ror_use_real_name_button'
    
    click 'reply_of_reply_submit_button'
    wait_while_present 'reply_of_reply_submit_button'

    commit_database
    
    validate_ror_content("some content")
    
    ror = ReplyOfReply.first(:conditions=>{:reply_id=>@reply.id})
    expect_html_to_include("reply_of_reply_content_#{ror.id}","ni")
    
  end
  
  it "reply to anonymous kratoo not successfully (same anonymous name)" do 
    @anonymous_kratoo = mock_anonymous_kratoo(@member,"Title","Content")
    
    @anonymous_kratoo.is_used_anonymous_name("Tanin_anonymous").should == true
    @anonymous_reply = mock_reply(@member, @anonymous_kratoo, "content")
    
    member = mock_member("ni","AAA","100002085428291")
    
    goto "/kratoo/view/#{@anonymous_kratoo.id}"
    
    open_ror_dialog(@anonymous_reply)
    login("ni","AAA")
    
    wait_until_present 'reply_of_reply_content'
    fill 'reply_of_reply_content', "some content"
    
    click 'ror_use_anonymous_name_button'
     fill 'reply_of_reply_username', "Tanin_anonymous"

    click 'reply_of_reply_submit_button'
    
    expect_html_to_include("reply_of_reply_error_panel",word_for(:kratoo,:username_redundant))
    
  end

end