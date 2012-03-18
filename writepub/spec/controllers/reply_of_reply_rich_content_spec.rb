require 'spec_helper'
require 'fileutils'

describe ReplyOfReplyController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include NotificationRspecHelper
  include MemberActionRspecHelper
  
  before(:each) do

    @member = mock_member("Tanin", "AAA")
    @kratoo = mock_kratoo(@member, "Title", "Content")
    @reply = mock_reply(@member, @kratoo, "ReplyContent")
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
    

    post :add, {:reply_id=>@reply.id,
                  :content=>content
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    body['ok'].should == true
    commit_database
    
    ror = ReplyOfReply.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_1.jpg")).should == false
    
    ror.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public", "")
    }
    
    ror.content.images[0].should == "/uploads/images/taylor_swift.jpg"
    ror.content.images[1].should == "/uploads/images/taylor_swift_1.jpg"
    
    ror.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    ror.content.html.should match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
  it "deletes unused files when editted correctly" do
             
    FileUtils.copy(File.expand_path("../../assets/taylor_swift.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift.jpg"))
                  
    FileUtils.copy(File.expand_path("../../assets/taylor_swift_1.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift_1.jpg"))
                  
    ror = mock_ror(@member, @reply, "Content")
    ror.content = RichContent.new
    ror.content.html = "\
      aaaaaa\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift.jpg\">\
      bbbbbbbbb\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift_1.jpg\">\
      cccccccccccc"
      
    ror.content.images = ["/uploads/images/taylor_swift.jpg", 
                              "/uploads/images/taylor_swift_1.jpg"]
    
    ror.content.text = "\
      aaaaaa\
      \
      bbbbbbbbb\
      \
      cccccccccccc"
      
    ror.save
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


    post :edit, {:reply_of_reply_id=>ror.id,
                  :content=>content
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    commit_database
    
    ror = ReplyOfReply.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_2.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_3.jpg")).should == true
    
    ror.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public","")
    }
    
    ror.content.images[0].should include("/uploads/images/taylor_swift.jpg")
    ror.content.images[1].should include("/uploads/images/taylor_swift_2.jpg")
    
    ror.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    ror.content.html.should match(/\/uploads\/images\/taylor_swift_2\.jpg/)
    
    ror.content.html.should_not match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
end