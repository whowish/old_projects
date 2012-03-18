require 'spec_helper'

describe ReplyController do
    include MemberRspecHelper
    include KratooRspecHelper
    include ReplyRspecHelper
    include ReplyOfReplyRspecHelper
    
    before(:each) do

      @member = mock_member("Tanin", "AAA")
      @kratoo = mock_kratoo(@member, "Title", "content")
      @reply = mock_reply(@member,@kratoo,"reply_content") 
      @ror = mock_ror(@member, @reply, "ror content")
      commit_database
      
    end

    it "should push ror action and delete it" do
      
      member_reply_of_reply(@reply.id,@member,"ReplyOfReply")
      expect_and_perform_queue(:member_action, 1)
      expect_and_perform_queue(:normal, 2)
      expect_and_perform_queue(:notification, 1)
      commit_database
      
      ror = ReplyOfReply.where(:reply_id=>@reply.id).asc(:created_date).skip(1).entries.first
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == ror.id
      
      delete_reply_of_reply(@member,ror.id)
      expect_and_perform_queue(:normal, 1)
      commit_database
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-ror action and delete it" do
      
      agree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
      unagree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-ror action and delete it because we push another disagree-ror action" do
      
      agree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
      disagree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
  end
  
  it "should push disagree-ror action and delete it" do
      
      disagree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
      unagree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push disagree-kratoo action and delete it because we push another agree-kratoo action" do
      
      disagree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
      agree_reply_of_reply(@member,@ror.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(ReplyOfReplyActionEntity)
      action.entity.reply_of_reply_id.should == @ror.id
      
  end
  
end