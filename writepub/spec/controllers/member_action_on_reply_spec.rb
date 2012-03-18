require 'spec_helper'

describe ReplyOfReplyController do
    include MemberRspecHelper
    include KratooRspecHelper
    include ReplyRspecHelper 
    
    before(:each) do

      @member = mock_member("Tanin", "AAA")
      @kratoo = mock_kratoo(@member, "Title", "content")
      @reply = mock_reply(@member, @kratoo, "reply_content") 
      commit_database
      
    end

    it "should push reply action and delete it" do
      
      
      # Replies will be ordered by time
      future = Time.now + 1000
      Time.stub!(:now).and_return(future)
      
      member_reply(@kratoo.id,@member,"Reply")
      expect_and_perform_queue(:member_action, 1)
      expect_and_perform_queue(:normal, 2)
      expect_and_perform_queue(:notification, 1)
      
      reply = Reply.where(:kratoo_id=>@kratoo.id).asc(:created_date).skip(1).entries.first
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == reply.id
      
      delete_reply(@member,reply.id)
      expect_and_perform_queue(:normal, 1)
      commit_database
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-reply action and delete it" do
      
      agree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
      unagree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-reply action and delete it because we push another disagree-reply action" do
      
      agree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
      disagree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
  end
  
  it "should push disagree-reply action and delete it" do
      
      disagree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
      unagree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push disagree-reply action and delete it because we push another agree-reply action" do
      
      disagree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
      agree_reply(@member,@reply.id)
      expect_and_perform_queue(:member_action, 1)
      commit_database
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyActionEntity)
      action.entity.reply_id.should == @reply.id
      
  end
  
end