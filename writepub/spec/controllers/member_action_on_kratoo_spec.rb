require 'spec_helper'

describe KratooController do
  
    include MemberRspecHelper
    include KratooRspecHelper
    
    before(:each) do

      @member = mock_member("Tanin", "AAA")
      @kratoo = mock_kratoo(@member,"Title","content")
      commit_database
      
    end

    it "should push post kratoo action and delete it" do
      
      kratoo_id = member_create_kratoo(@member,"TestTitle","TestContent")
      
      expect_and_perform_queue(:member_action, 1)
      expect_and_perform_queue(:normal, 2)
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == kratoo_id
      
      delete_kratoo(@member,kratoo_id)
      expect_and_perform_queue(:normal, 1)
      
      action = PostMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-kratoo action and delete it" do
      
      agree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
      unagree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push agree-kratoo action and delete it because we push another disagree-kratoo action" do
      
      agree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
      disagree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
  end
  
  it "should push disagree-kratoo action and delete it" do
      
      disagree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
      unagree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
    end
  
    it "should push disagree-kratoo action and delete it because we push another agree-kratoo action" do
      
      disagree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
      agree_kratoo(@member,@kratoo.id)
      expect_and_perform_queue(:member_action, 1)
      
      action = DisagreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.should be_nil
      
      action = AgreeMemberAction.first(:conditions=>{:member_id=>@member.id})
      action.entity.should be_an_instance_of(KratooActionEntity)
      action.entity.kratoo_id.should == @kratoo.id
      
  end
  
end