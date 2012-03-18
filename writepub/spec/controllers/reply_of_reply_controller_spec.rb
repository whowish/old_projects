require 'spec_helper'

describe ReplyOfReplyController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky", "AAAC")
    @other_member_2 = mock_member("Walnut", "AAAD")
  end
  
  it "is replied by Walnut, a member(public), and a member(anonymous)." do
    
    kratoo_id = member_create_kratoo(@member, "Title", "Content")
    member_reply(kratoo_id, @other_member_1, "Reply")
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    reply = kratoo.replies[0]
    
    member_reply_of_reply(reply.id,@other_member_1,"ReplyOfReply 1");sleep(2)
    anonymous_reply_of_reply(reply.id,@other_member_0,"Anonymous","ReplyOfReply 2");sleep(2)
    member_reply_of_reply(reply.id,@other_member_2,"ReplyOfReply 3");sleep(2)
    anonymous_reply_of_reply(reply.id,@other_member_0,"Anonymous","ReplyOfReply 4");sleep(2)
    member_reply_of_reply(reply.id,@other_member_2,"ReplyOfReply 5");sleep(2)
    
    expect_and_perform_queue(:notification, 6)
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.replies.length.should == 1
    
    reply = kratoo.replies[0]
    
    reply.replies.length.should == 5
    
    rors = ReplyOfReply.where(:reply_id=>reply.id).asc(:created_date)
    
    rors[0].content.text == "ReplyOfReply 1"
    rors[0].post_owner.should be_an_instance_of(OwnerPublic)
    rors[0].post_owner.username.should == @other_member_1.username
    rors[0].post_owner.member_id.should == @other_member_1.id
    
    rors[1].content.text == "ReplyOfReply 2"
    rors[1].post_owner.should be_an_instance_of(OwnerAnonymous)
    rors[1].post_owner.username.should == "Anonymous"
    rors[1].post_owner.member_id.should == @other_member_0.id
    
    rors[2].content.text == "ReplyOfReply 3"
    rors[2].post_owner.should be_an_instance_of(OwnerPublic)
    rors[2].post_owner.username.should == @other_member_2.username
    rors[2].post_owner.member_id.should == @other_member_2.id
    
    rors[3].content.text == "ReplyOfReply 4"
    rors[3].post_owner.should be_an_instance_of(OwnerAnonymous)
    rors[3].post_owner.username.should == "Anonymous"
    rors[3].post_owner.member_id.should == @other_member_0.id
    
    rors[4].content.text == "ReplyOfReply 5"
    rors[4].post_owner.should be_an_instance_of(OwnerPublic)
    rors[4].post_owner.username.should == @other_member_2.username
    rors[4].post_owner.member_id.should == @other_member_2.id
    
    kratoo.get_anonymous_name(@other_member_0).should == "Anonymous"
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ ["Anonymous"]
    kratoo.is_anonymous_name_used("Anonymous").should == true
   
    notification = ReplyNotification.first(:conditions=>{:kratoo_id=>kratoo.id,
                                                          :notified_member_id=>@member.id,
                                                          :is_read=>false})
    notification.names.map { |i| i.username}.should =~ [@other_member_1.username]
    
    notification = ReplyOfReplyNotification.first(:conditions=>{:kratoo_id=>kratoo.id,
                                                                :reply_id=>reply.id,
                                                                :notified_member_id=>@other_member_1.id,
                                                                :is_read=>false})
    notification.names.map { |i| i.username}.should =~ [@other_member_2.username, "Anonymous"]
    
    notification = ReplyOfReplyNotification.first(:conditions=>{:kratoo_id=>kratoo.id,
                                                                :reply_id=>reply.id,
                                                                :notified_member_id=>@other_member_0.id,
                                                                :is_read=>false})
    notification.names.map { |i| i.username}.should =~ [@other_member_2.username]
  end
  
  it "is edited by a member" do
   
    kratoo_id = member_create_kratoo(@member,"Title","Content")
    member_reply(kratoo_id,@other_member_0,"This is a member reply.")
    commit_database
 
    kratoo = Kratoo.find(kratoo_id)
    reply = kratoo.replies[0]
 
    member_reply_of_reply(reply.id,@other_member_1,"ReplyOfReply 1")
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    reply = kratoo.replies[0]
    r_o_r = reply.replies[0]
   
    post :edit, {
                                :content=>"This is a member r_o_r edit",
                                :reply_of_reply_id=>r_o_r.id
                               },
                                mock_member_session(@other_member_1)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    kratoo_id = body['kratoo_id']
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.reply_count.should == 1
    kratoo.all_reply_count.should == 2
    
    reply = kratoo.replies[0]
    r_o_r = reply.replies[0]
    r_o_r.content.text.should == "This is a member r_o_r edit" 
    r_o_r.post_owner.should be_an_instance_of(OwnerPublic)
    r_o_r.post_owner.username.should == @other_member_1.username
    
    versioning_reply_of_reply = VersioningReplyOfReply.all(:conditions=>{:reply_of_reply_id=>r_o_r.id})
    versioning_reply_of_reply.count.should == 2
    
  end 
  
  it "is deleted by a member" do
   
    kratoo = mock_kratoo(@member, "Title", "Content")
    reply = mock_reply(@member, kratoo, "Reply")
    ror = mock_ror(@member, reply, "RoR")
    commit_database
    
    post :delete, {
                   :reply_of_reply_id=>ror.id
                  },
                  mock_member_session(@other_member_1)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    commit_database
    
    expect_and_perform_queue(:normal, 1)
    commit_database
  
    deleted_reply_of_reply = DeletedReplyOfReply.first(:conditions=>{:reply_of_reply_id=>ror.id})
    deleted_reply_of_reply.deleted_member_id.to_s.should == @other_member_1.id.to_s
    
    deleted_reply_of_reply.object_data.should be_an_instance_of(ReplyOfReply)
    
    kratoo = Kratoo.first(:conditions=>{:id=>kratoo.id})
    kratoo.reply_count.should == 1
    kratoo.all_reply_count.should == 1
    
    reply_of_reply = ReplyOfReply.first(:conditions=>{:id=>ror.id})
    reply_of_reply.should be_nil
    
  end 
  
  
end
