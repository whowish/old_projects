require 'spec_helper'
require 'fileutils'

describe KratooController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include NotificationRspecHelper
  include MemberActionRspecHelper
  
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
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
    

    post :add, {:title=>"TestTitle",
                  :content=>content,
                  :kratoo_type=>Kratoo::TYPE_GENERAL,
                  :tags=>"A,B,C"
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    commit_database
    
    kratoo = Kratoo.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_1.jpg")).should == false
    
    kratoo.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public", "")
    }
    
    kratoo.content.images[0].should == "/uploads/images/taylor_swift.jpg"
    kratoo.content.images[1].should == "/uploads/images/taylor_swift_1.jpg"
    
    kratoo.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    kratoo.content.html.should match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
  it "deletes unused files when editted correctly" do
             
    FileUtils.copy(File.expand_path("../../assets/taylor_swift.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift.jpg"))
                  
    FileUtils.copy(File.expand_path("../../assets/taylor_swift_1.jpg",__FILE__), 
                  File.join(Rails.root, "public/uploads/images/taylor_swift_1.jpg"))
                  
    kratoo = mock_kratoo(@member,"Title","Content")
    kratoo.content = RichContent.new
    kratoo.content.html = "\
      aaaaaa\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift.jpg\">\
      bbbbbbbbb\
      <img src=\"http://#{DOMAIN_NAME}/uploads/images/taylor_swift_1.jpg\">\
      cccccccccccc"
      
    kratoo.content.images = ["/uploads/images/taylor_swift.jpg", 
                              "/uploads/images/taylor_swift_1.jpg"]
    
    kratoo.content.text = "\
      aaaaaa\
      \
      bbbbbbbbb\
      \
      cccccccccccc"
      
    kratoo.save
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


    post :edit_kratoo, {:title=>"TestTitle",
                  :content=>content,
                  :kratoo_id=>kratoo.id
                  } ,
                  mock_member_session(@member)

    body = expect_json_response
    commit_database
    
    kratoo = Kratoo.first
    
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_2.jpg")).should == false
    File.exists?(File.join(Rails.root, "public/uploads/temp/taylor_swift_3.jpg")).should == true
    
    kratoo.content.images.should =~ Dir[File.join(Rails.root, "public", "uploads/images/*")].map { |full_path|
        full_path.sub("#{Rails.root}/public","")
    }
    
    kratoo.content.images[0].should include("/uploads/images/taylor_swift.jpg")
    kratoo.content.images[1].should include("/uploads/images/taylor_swift_2.jpg")
    
    kratoo.content.html.should match(/\/uploads\/images\/taylor_swift\.jpg/)
    kratoo.content.html.should match(/\/uploads\/images\/taylor_swift_2\.jpg/)
    
    kratoo.content.html.should_not match(/\/uploads\/images\/taylor_swift_1\.jpg/)
    
  end
  
end