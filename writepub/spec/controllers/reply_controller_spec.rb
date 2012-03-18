require 'spec_helper'


describe ReplyController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  
  # Stub
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky", "AAAC")
    @other_member_2 = mock_member("Walnut", "AAAD")
    commit_database
    
  end
  
  it "is replied by a guest (not allowed)" do
    
    kratoo_id = member_create_kratoo(@member,"Title","Content")
    
    member_reply(kratoo_id, Member.get_guest, "hello")

    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['summary'].should == word_for(:kratoo,:do_not_allow_guest)
    
  end

  it "is replied by Walnut, a member who agrees to share his name, a member who hides his name, and again Walnut. The notification should be merged for the first user. And another notification should be added for the second user." do
    
    kratoo_id = member_create_kratoo(@member, "Title","Content")
    member_reply(kratoo_id, @other_member_2, "This is a walnut reply.")
    member_reply(kratoo_id, @other_member_0, "This is a member reply.")
    anonymous_reply(kratoo_id, @other_member_1, "AnonymousName", "This is a anonymous reply.")
    member_reply(kratoo_id, @other_member_2, "This is a walnut reply 2.")
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.reply_count.should == 4
    kratoo.replies.length.should == 4
    
    replies = Reply.where(:kratoo_id=>kratoo.id).asc(:reply_running_number).entries
    
    replies[0].post_owner.should be_an_instance_of(OwnerPublic)
    replies[0].post_owner.username == @other_member_2.username
    replies[0].content.text == "This is a walnut's reply."
    
    replies[1].post_owner.should be_an_instance_of(OwnerPublic)
    replies[1].post_owner.username == @other_member_0.username
    replies[1].content.text == "This is a member reply."
    
    replies[2].post_owner.should be_an_instance_of(OwnerAnonymous)
    replies[2].post_owner.username == "AnonymousName"
    replies[2].content.text == "This is a anonymous reply."
    
    kratoo.get_anonymous_name(@other_member_1).should == "AnonymousName"
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ ["AnonymousName"]
    kratoo.is_anonymous_name_used("AnonymousName").should == true

    replies[3].post_owner.should be_an_instance_of(OwnerPublic)
    replies[3].post_owner.username == @other_member_2.username
    replies[3].content.text == "This is a walnut reply 2."
    
    expect_and_perform_queue(:notification, 4)
    
    notification = ReplyNotification.first(:conditions=>{:notified_member_id=>@member.id,
                                                          :kratoo_id=>kratoo_id,
                                                          :is_read=>false})
    notification.names.map { |i| i.username}.should =~ ["AnonymousName",@other_member_0.username,@other_member_2.username]
    
    notification = ReplyNotification.first(:conditions=>{:notified_member_id=>@other_member_0.id,
                                                          :kratoo_id=>kratoo_id,
                                                          :is_read=>false})
    notification.names.map { |i| i.username}.should =~ ["AnonymousName",@other_member_2.username]
    
  end
  
  it "does not allow redundant anonymous name" do
    
    kratoo_id = member_create_kratoo(@member, "Title","Content")
    anonymous_reply(kratoo_id, @other_member_0, "AnonymousName", "This is a anonymous reply.")
    
    body = anonymous_reply(kratoo_id, @other_member_1, "AnonymousName", "This is a anonymous reply.")

    body['ok'].should == false
    body['error_messages']['username'].should == WhowishWord.word_for(:kratoo, :username_redundant)
    
    kratoo = Kratoo.find(kratoo_id)
    
    kratoo.get_anonymous_name(@other_member_1).should == ""
    kratoo.get_anonymous_name(@other_member_0).should == "AnonymousName"
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ ["AnonymousName"]
    kratoo.is_anonymous_name_used("AnonymousName").should == true
    
  end
  
  it "set user as anonymous if the user was anonymous before, even though the request says it is public." do
    
    kratoo_id = member_create_kratoo(@member, "Title","Content")
    anonymous_reply(kratoo_id, @other_member_0, "AnonymousName", "This is a anonymous reply.")
    body = member_reply(kratoo_id, @other_member_0, "content")
    body['ok'].should == true
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.replies.each { |reply|
      reply.post_owner.should be_an_instance_of(OwnerAnonymous)
    }
    
    kratoo.get_anonymous_name(@other_member_0).should == "AnonymousName"
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ ["AnonymousName"]
    kratoo.is_anonymous_name_used("AnonymousName").should == true
    
  end
  
  it "set user as public if the user was public before, even though the request says it is anonymous." do
    
    kratoo_id = member_create_kratoo(@member, "Title","Content")
    member_reply(kratoo_id, @other_member_0, "content")
    
    body = anonymous_reply(kratoo_id, @other_member_0, "AnonymousName", "This is a anonymous reply.")
    body['ok'].should == true
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.replies.each { |reply|
      reply.post_owner.should be_an_instance_of(OwnerPublic)
    }
    
    kratoo.get_anonymous_name(@other_member_0).should == ""
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ []
    kratoo.is_anonymous_name_used("AnonymousName").should == false
    
  end
  
  it "is edited by a member" do
   
    kratoo_id = member_create_kratoo(@member,"Title","Content")
    member_reply(kratoo_id,@other_member_0,"This is a member reply.")
    commit_database   

    kratoo = Kratoo.find(kratoo_id)
    reply_id = kratoo.replies[0].id
   
   post :edit, {
                :content=>"This is a member reply edit",
                :reply_id=>reply_id
                },
                mock_member_session(@member)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    kratoo_id = body['kratoo_id']
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.reply_count.should == 1
    kratoo.all_reply_count.should == 1
    
    reply = kratoo.replies[0]
    reply.content.text.should == "This is a member reply edit" 
    reply.post_owner.should be_an_instance_of(OwnerPublic)
    reply.post_owner.username.should == @other_member_0.username
    
    versioning_reply = VersioningReply.all(:conditions=>{:kratoo_id=>kratoo_id})
    versioning_reply.count.should == 2
    
  end 
  
  it "is deleted by a member" do
   
    kratoo_id = member_create_kratoo(@member,"Title","Content")
    member_reply(kratoo_id,@other_member_0,"This is a member reply.")
   
    commit_database

    kratoo = Kratoo.find(kratoo_id)
    reply_id = kratoo.replies[0].id
   
    post :delete, {
                    :reply_id=>reply_id
                  },
                  mock_member_session(@other_member_0)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    commit_database
  
    deleted_reply = DeletedReply.first(:conditions=>{:reply_id=>reply_id})
    deleted_reply.deleted_member_id.to_s.should == @other_member_0.id.to_s
    
    deleted_reply.object_data.should be_an_instance_of(Reply)
    
    kratoo = Kratoo.first(:conditions=>{:id=>kratoo_id})
    kratoo.reply_count.should == 0
    kratoo.all_reply_count.should == 0
    
    reply = Reply.first(:conditions=>{:id=>reply_id})
    reply.should be_nil
    
  end 
  
  it "is deleted by a member with reply of reply" do
   
    kratoo = mock_kratoo(@member, "Title", "Content")
    reply = mock_reply(@member, kratoo, "Reply")
    ror = mock_ror(@member, reply, "RoR")
    commit_database
   
   
    post :delete, {
                    :reply_id=>reply.id
                  },
                  mock_member_session(@other_member_0)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    commit_database
    expect_and_perform_queue(:normal, 1)
    commit_database
    
    deleted_objects = DeletedObject.all
    deleted_objects.count.should == 2

    deleted_reply = DeletedReply.first(:conditions=>{:reply_id=>reply.id})
    deleted_reply.deleted_member_id.to_s.should == @other_member_0.id.to_s
    deleted_reply.object_data.should be_an_instance_of(Reply)
    
    deleted_ror = DeletedReplyOfReply.first(:conditions=>{:reply_of_reply_id=>ror.id})
    deleted_ror.deleted_member_id.to_s.should == @other_member_0.id.to_s
    deleted_ror.object_data.should be_an_instance_of(ReplyOfReply)
    
    reply = Reply.first(:conditions=>{:id=>reply.id})
    reply.should be_nil
    
    ror = ReplyOfReply.first(:conditions=>{:id=>ror.id})
    ror.should be_nil
    
  end 
end
