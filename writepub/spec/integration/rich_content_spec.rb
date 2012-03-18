# encoding: utf-8
require 'spec_helper'
require 'fileutils'

describe KratooController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include LoginRspecHelper
  include FacebookConnectRspecHelper
  
  before(:each) do
    
    @member = mock_member("Tanin","AAA")
    commit_database
    
    Dir[File.join(Rails.root, "public/uploads/temp/*")].each { |f| 
      FileUtils.remove(f, :force=>true)
    }
    
    Dir[File.join(Rails.root, "public/uploads/images/*")].each { |f| 
      FileUtils.remove(f, :force=>true)
    }
    
  end
  
  it "upload files correctly, when creating kratoo" do

    goto '/kratoo'
    expect_html_to_include("kratoo_submit_panel_require_login",word_for("kratoo/_new_general.html.erb",:please_login))
    
    kratoo_login("Tanin","AAA")
    
    fill 'kratoo_title', 'อั้มน่ารัก'
    fill 'kratoo_content',  "Test Content"
    
    element(:id=>"kratoo_content_toolbar").element(:class=>"image_button").click

    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift.jpg", __FILE__))
                  
    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift_1.jpg", __FILE__))
                  
    click "writepub_editor_thumbnail_unit_0"
    click "writepub_editor_thumbnail_unit_1"
    click "writepub_editor_insert_image_button"
    
    
    click 'kratoo_submit_button'
    expect_path_to_be /^\/kratoo\/view\//
    
    html('kratoo_content').should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html('kratoo_content').should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
    
  end
  
  it "upload files correctly, when creating reply" do
    
    kratoo = mock_kratoo(@member, "Title", "Content")


    goto "/kratoo/view/#{kratoo.id}"

    reply_login("Tanin","AAA")
    
    fill 'reply_content',  "Test Content"
    
    element(:id=>"reply_content_toolbar").element(:class=>"image_button").click

    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift.jpg", __FILE__))
                  
    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift_1.jpg", __FILE__))
                  
    click "writepub_editor_thumbnail_unit_0"
    click "writepub_editor_thumbnail_unit_1"
    click "writepub_editor_insert_image_button"
    
    click 'reply_submit_button'
    commit_database
    
    reply = Reply.first(:conditions=>{:kratoo_id=>kratoo.id})
    
    html("reply_#{reply.id}").should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html("reply_#{reply.id}").should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
    value("reply_content").should == ""
    
  end

  it "upload files correctly, when creating ror" do

  
    kratoo = mock_kratoo(@member, "Title", "Content")
    reply = mock_reply(@member, kratoo, "Reply")

    goto "/kratoo/view/#{kratoo.id}"

    open_ror_dialog(reply)
    reply_of_reply_login("Tanin","AAA")
    
    fill 'reply_of_reply_content',  "Test Content"
    
    element(:id=>"reply_of_reply_content_toolbar").element(:class=>"image_button").click

    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift.jpg", __FILE__))
                  
    upload_file("writepub_editor_upload_button",
                  "AjaxUploadButton_writepub_editor_upload_button",
                  File.expand_path("../../assets/taylor_swift_1.jpg", __FILE__))
                  
    click "writepub_editor_thumbnail_unit_0"
    click "writepub_editor_thumbnail_unit_1"
    click "writepub_editor_insert_image_button"
    
    click 'reply_of_reply_submit_button'
    commit_database
    
    ror = ReplyOfReply.first(:conditions=>{:reply_id=>reply.id})
    
    html("reply_of_reply_#{ror.id}").should match(/<img src="\/uploads\/images\/taylor_swift-[a-zA-Z0-9]+\.jpg">/)
    html("reply_of_reply_#{ror.id}").should match(/<img src="\/uploads\/images\/taylor_swift_1-[a-zA-Z0-9]+\.jpg">/)
    value("reply_of_reply_content").should == ""

  end
  
end