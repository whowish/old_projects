require 'spec_helper'

describe 'ReplyOfReplyController' do
  
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include MemberRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin","AAA")
    @kratoo = mock_kratoo(@member, "Title", "Content")
    @reply = mock_reply(@member, @kratoo, "Content")
    @ror = mock_ror(@member, @reply, "ror content")
    commit_database
    
  end
  
  
  it "edit successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@ror.id}"
   
    expect_path_to_be "/reply_of_reply/edit_form"
    fill 'content', 'edit_ror_content'
    
    click 'post_kratoo_button'
    commit_database
    
    expect_path_to_be "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_content_#{@ror.id}",'edit_ror_content')
    
  end
  
  it "edit failed (Client side)" do 
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@ror.id}"
    expect_path_to_be "/reply_of_reply/edit_form"
   
    fill 'content', ""

    click 'post_kratoo_button'
    expect_html_to_include("reply_of_reply_edit_error_panel",word_for(:reply_of_reply_edit,:content_presence))
    
  end
  
   it "edit failed (Server side)", :js => true do 

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@ror.id}"
    expect_path_to_be "/reply_of_reply/edit_form"
    
    execute_script("reply_of_reply_edit_validator.validate_all = function() {return true;}");
        
    fill 'content', ""
   
    click 'post_kratoo_button'
   
    expect_html_to_include("reply_of_reply_edit_error_panel",word_for(:reply_of_reply_edit,:content_presence))
    
  end
  
  it "edit rich content successfully" do
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "edit_reply_#{@ror.id}"
   
    expect_path_to_be "/reply_of_reply/edit_form"
    fill 'content', 'edit_ror_content'
    
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
    expect_html_to_include("reply_of_reply_content_#{@ror.id}",'edit_ror_content')
    
    html("reply_of_reply_content_#{@ror.id}").should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html("reply_of_reply_content_#{@ror.id}").should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
  end


  
end