require 'spec_helper'


describe KratooController do
  
  include MemberRspecHelper
  include KratooRspecHelper

  
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky","AAAC")
    @kratoo = mock_kratoo(@member,"Title","Content")
    commit_database
    
  end

  it "First user likes and likes, Second user dislikes and likes" do
  
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 0)

      disagree_kratoo(@other_member_1,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      agree_kratoo(@other_member_1,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      @kratoo = Kratoo.find(@kratoo.id)
      @kratoo.agrees.should == 2
      @kratoo.disagrees.should == 0
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.count.should == 2
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username,@other_member_1.username]

      disagree_notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                        :notified_member_id=>@member.id,
                                                                        :is_read=>false})
      disagree_notification.should be_nil
      
      @member = Member.find(@member.id)
      @member.fame.should == 2
      
      @kratoo.is_agree_or_disagree(@other_member_0.id).should == Kratoo::AGREEABLE_TYPE_AGREE
      @kratoo.is_agree_or_disagree(@other_member_1.id).should == Kratoo::AGREEABLE_TYPE_AGREE
      
    end
    
    it "User agrees and unagrees, the notification should be deleted(1)" do
      
      agree_kratoo(@other_member_1,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      @member = Member.find(@member.id)
      @member.fame.should == 1
      
      unagree_kratoo(@other_member_1,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      

      @kratoo = Kratoo.find(@kratoo.id)
      @kratoo.agrees.should == 0
      @kratoo.disagrees.should == 0

      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.should be_nil
      
      unagree_notification = UnagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      unagree_notification.should be_nil
      
      @member = Member.find(@member.id)
      @member.fame.should == 0
      
    end
    
    it "User agrees and unagrees, the notification should be deleted(2)" do

      agree_kratoo(@other_member_1,@kratoo.id)
      unagree_kratoo(@other_member_1,@kratoo.id)
      
      expect_and_perform_queue(:notification, 2)
      
      
      @kratoo = Kratoo.find(@kratoo.id)
      @kratoo.agrees.should == 0
      @kratoo.disagrees.should == 0
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.should be_nil
      
      unagree_notification = UnagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      unagree_notification.should be_nil
      
      @member = Member.find(@member.id)
      @member.fame.should == 0
      
    end
    
    it "should change agree to disagree and change the notification when user change his/her mind" do
      
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      @member = Member.find(@member.id)
      @member.fame.should == 1
      

      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
 
 
      @kratoo = Kratoo.find(@kratoo.id)
      @kratoo.agrees.should == 0
      @kratoo.disagrees.should == 1
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.should be_nil
      
      disagree_notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                        :notified_member_id=>@member.id,
                                                                        :is_read=>false})
      disagree_notification.count.should == 1
      disagree_notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
      @member = Member.find(@member.id)
      @member.fame.should == 0
      
    end
    
    it "is agreed, read, then disagreed" do
      
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      # read
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.is_read = true
      notification.save
      commit_database
      
      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>true})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
      disagree_notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                        :notified_member_id=>@member.id,
                                                                        :is_read=>false})
      disagree_notification.count.should == 1
      disagree_notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
    
    it "is agreed, read, then unagreed" do
      
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.is_read = true
      notification.save
      commit_database
      
      unagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>true})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
      unagree_notification = UnagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                      :notified_member_id=>@member.id,
                                                                      :is_read=>false})
      unagree_notification.count.should == 1
      unagree_notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
    
    it "is disagreed, read, then unagreed" do
      
      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      # read
      notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                              :notified_member_id=>@member.id,
                                                              :is_read=>false})
      notification.is_read = true
      notification.save
      commit_database
      
      unagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                              :notified_member_id=>@member.id,
                                                              :is_read=>true})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
      unagree_notification = UndisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                        :notified_member_id=>@member.id,
                                                                        :is_read=>false})
      unagree_notification.count.should == 1
      unagree_notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
    
    it "is agreed, unagreed, then disagreed" do
      
      agree_kratoo(@other_member_0,@kratoo.id)
      unagree_kratoo(@other_member_0,@kratoo.id)
      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 3)
      
      notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                              :notified_member_id=>@member.id,
                                                              :is_read=>false})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
      agree_notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                  :notified_member_id=>@member.id,
                                                                  :is_read=>false})
      agree_notification.should be_nil
      
      unagree_notification = UnagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                                      :notified_member_id=>@member.id,
                                                                      :is_read=>false})
      unagree_notification.should be_nil
    end
    
    it "is agreed, unagreed, then agreed" do
      
      agree_kratoo(@other_member_0,@kratoo.id)
      unagree_kratoo(@other_member_0,@kratoo.id)
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 3)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
    
    it "is disagreed, undisagreed, then agreed" do
      
      disagree_kratoo(@other_member_0,@kratoo.id)
      unagree_kratoo(@other_member_0,@kratoo.id)
      agree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 3)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
    
    it "is disagreed, undisagreed, then disagreed" do
      
      disagree_kratoo(@other_member_0,@kratoo.id)
      unagree_kratoo(@other_member_0,@kratoo.id)
      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 3)
      
      notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                              :notified_member_id=>@member.id,
                                                              :is_read=>false})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    end
    
    it "is unagreed, then disagreed" do
      
      unagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 0)
      
      notification = AgreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                            :notified_member_id=>@member.id,
                                                            :is_read=>false})
      notification.should be_nil
      
      disagree_kratoo(@other_member_0,@kratoo.id)
      expect_and_perform_queue(:notification, 1)
      
      notification = DisagreeNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id,
                                                              :notified_member_id=>@member.id,
                                                              :is_read=>false})
      notification.count.should == 1
      notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
      
    end
  end