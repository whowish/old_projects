# encoding: utf-8
require 'spec_helper'

describe 'KratooController' do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include LoginRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin","AAA",nil)
    @kratoo = mock_kratoo(@member,"Title","content")
    commit_database
    
  end
  
  it "edit successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'edit_kratoo'
    expect_path_to_be "/kratoo/edit"
    fill 'title', 'edit_title'
    fill 'content', 'edit_content'
    
    click 'post_kratoo_button'
    commit_database
    
    expect_path_to_be "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("kratoo_title",'edit_title')
    expect_html_to_include("kratoo_content",'edit_content')
  end
  
  it "edit failed (Client side)" do 
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'edit_kratoo'
    expect_path_to_be "/kratoo/edit"
    fill 'title', ''
   
    expect_html_to_include("kratoo_title_error_panel",word_for(:kratoo_edit,:title_presence))
    
    
    long_content = ""
    257.times { long_content << 'a' }
    fill 'title', ''
    fill'title', long_content
    fill 'content', ""
    expect_html_to_include("kratoo_title_error_panel",word_for(:kratoo_edit,:title_max_length))
  
    click 'post_kratoo_button'
    expect_html_to_include("kratoo_edit_error_panel",word_for(:kratoo_edit,:title_max_length))
    expect_html_to_include("kratoo_edit_error_panel",word_for(:kratoo_edit,:content_presence))
    
  end
  
   it "edit failed (Server side)", :js => true do 

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'edit_kratoo'
    expect_path_to_be "/kratoo/edit"
    
    execute_script("kratoo_edit_validator.validate_all = function() {return true;}");
        
    fill 'title', ''
    
    long_content = ""
    256.times { long_content << 'a' }
    fill 'title', long_content

    fill 'content', "Test Content"
    fill 'content', ""
   
    click 'post_kratoo_button'
    
    expect_html_to_include("kratoo_edit_error_panel",word_for(:kratoo_edit,:title_max_length))
    expect_html_to_include("kratoo_edit_error_panel",word_for(:kratoo_edit,:content_presence))
    
  end
  
  it "edit rich content successfully" do
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    click 'edit_kratoo'
    expect_path_to_be "/kratoo/edit"
    fill 'title', 'edit_title'
    fill 'content', 'edit_content'
    
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
    expect_html_to_include("kratoo_title",'edit_title')
    expect_html_to_include("kratoo_content",'edit_content')
   
    html('kratoo_content').should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html('kratoo_content').should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
  end
  
    
 end