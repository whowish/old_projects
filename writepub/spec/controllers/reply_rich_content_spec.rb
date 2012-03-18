require 'spec_helper'
require 'fileutils'

describe ReplyController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include NotificationRspecHelper
  include MemberActionRspecHelper
  
  before(:each) do

    @member = mock_member("Tanin", "AAA")
    @kratoo = mock_kratoo(@member, "Title", "Content")
    commit_database
    
    Dir[File.join(Rails.root, "public/uploads/temp/*")].each { |f| 
      FileUtils.remove(f, :force=>true)
    }
    
    Dir[File.join(Rails.root, "public/uploads/images/*")].each { |f| 
      FileUtils.remove(f, :force=>true)
    }
    
  end
  
  it "moves files and delete temporary files correctly" do

    FileUtils.copy(File.expand_path("../../assets/taylor_swift_1.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/temp/taylor_swift_1.jpg"))
                  
    FileUtils.copy(File.expand_path("../../assets/taylor_swift.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/temp/taylor_swift.jpg"))


    content = "\
      aaaaaa\
      <img src=\"http://#{DOMAIN_NAME}/uploads/temp/taylor_swift.jpg\">\
      bbbbbbbbb\
      <img src=\"http://#{DOMAIN_NAME}/uploads/temp/taylor_swift_1.jpg\">\
      cccccccccccc"
    

    post :add, {:kratoo_id=>@kratoo.id,
                  :content=>content
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    body['ok'].should == true
    commit_database
    
    reply = Reply.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_1.jpg")).should == false
    
    reply.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public", "")
    }
    
    reply.content.images[0].should == "/uploads/images/taylor_swift.jpg"
    reply.content.images[1].should == "/uploads/images/taylor_swift_1.jpg"
    
    reply.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    reply.content.html.should match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
  it "deletes unused files when editted correctly" do
             
    FileUtils.copy(File.expand_path("../../assets/taylor_swift.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift.jpg"))
                  
    FileUtils.copy(File.expand_path("../../assets/taylor_swift_1.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift_1.jpg"))
                  
    reply = mock_reply(@member, @kratoo, "Content")
    reply.content = RichContent.new
    reply.content.html = "\
      aaaaaa\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift.jpg\">\
      bbbbbbbbb\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift_1.jpg\">\
      cccccccccccc"
      
    reply.content.images = ["/uploads/images/taylor_swift.jpg", 
                              "/uploads/images/taylor_swift_1.jpg"]
    
    reply.content.text = "\
      aaaaaa\
      \
      bbbbbbbbb\
      \
      cccccccccccc"
      
    reply.save
    commit_database
                 
    FileUtils.copy(File.expand_path("../../assets/taylor_swift_2.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/temp/taylor_swift_2.jpg"))
                  
    FileUtils.copy(File.expand_path("../../assets/taylor_swift_3.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/temp/taylor_swift_3.jpg"))


    content = "\
      aaaaaa\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift.jpg\">\
      bbbbbbbbb\
      <img src=\"http://#{DOMAIN_NAME}/uploads/temp/taylor_swift_2.jpg\">\
      cccccccccccc"


    post :edit, {:reply_id=>reply.id,
                  :content=>content
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    commit_database
    
    reply = Reply.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_2.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_3.jpg")).should == true
    
    reply.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public","")
    }
    
    reply.content.images[0].should include("/uploads/images/taylor_swift.jpg")
    reply.content.images[1].should include("/uploads/images/taylor_swift_2.jpg")
    
    reply.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    reply.content.html.should match(/\/uploads\/images\/taylor_swift_2\.jpg/)
    
    reply.content.html.should_not match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
end