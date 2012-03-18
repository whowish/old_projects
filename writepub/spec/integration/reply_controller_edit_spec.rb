# encoding: utf-8
require 'spec_helper'

describe 'ReplyController' do
  
  include KratooRspecHelper
  include ReplyRspecHelper
  include MemberRspecHelper
  include FacebookConnectRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin","AAA",nil)
    @kratoo = mock_kratoo(@member,"Title","content")
    @reply = mock_reply(@member, @kratoo, "reply content")
    commit_database
    
  end
  
  it "edit successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)

    click "edit_reply_#{@reply.id}"
    expect_path_to_be "/reply/edit_form"
    fill 'content', 'edit_reply_content'
    
    click 'post_kratoo_button'
    commit_database
    
    expect_path_to_be "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_content_#{@reply.id}",'edit_reply_content')
  end
  
  it "edit failed (Client side)" do 
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@reply.id}"
    expect_path_to_be "/reply/edit_form"
   
    fill 'content', ""

    click 'post_kratoo_button'
    expect_html_to_include("reply_edit_error_panel",word_for(:reply_edit,:content_presence))
    
  end
  
   it "edit failed (Server side)", :js => true do 

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@reply.id}"
    expect_path_to_be "/reply/edit_form"
    
    execute_script("reply_edit_validator.validate_all = function() {return true;}");
        
    
    fill 'content', ""
   
    click 'post_kratoo_button'
   
    expect_html_to_include("reply_edit_error_panel",word_for(:reply_edit,:content_presence))
    
  end
  
  it "edit rich content successfully" do
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)

    click "edit_reply_#{@reply.id}"
    expect_path_to_be "/reply/edit_form"
    
    fill 'content', 'edit_reply_content'
    
    element(:id=>"content_toolbar").element(:class=>"image_button").click

    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift.jpg", __FILE__))
                  
    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift_1.jpg", __FILE__))
                  
    click "writepub_editor_thumbnail_unit_0"
    click "writepub_editor_thumbnail_unit_1"
    click "writepub_editor_insert_image_button"
    
    click 'post_kratoo_button'
    commit_database
    
    expect_path_to_be "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_content_#{@reply.id}",'edit_reply_content')
    
    html("reply_content_#{@reply.id}").should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html("reply_content_#{@reply.id}").should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
  end
  
    
 end