require 'spec_helper'


describe ReplyController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper 
  
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky", "AAAC")
    @other_member_2 = mock_member("Walnut", "AAAD")
    
    @kratoo = mock_kratoo(@member,"Title","Content")
    @reply = mock_reply(@other_member_0,@kratoo, "replyContent")
    commit_database
    
  end
  
  it "is liked (by one) and disliked (by another) and should notify the post's owner correctly" do

    agree_reply(@member,@reply.id)
    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 2)
    
    @reply = Reply.find(@reply.id)
    @reply.agrees.should == 1
    @reply.disagrees.should == 1
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@member.username]
    
    disagree_notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                                    :notified_member_id=>@other_member_0.id,
                                                                    :is_read=>false})
    disagree_notification.count.should == 1
    disagree_notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "First user likes and likes, Second user dislikes and likes" do
 
    agree_reply(@member,@reply.id)
    agree_reply(@member,@reply.id)
    disagree_reply(@other_member_1,@reply.id)
    agree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 3)
    
    @reply = Reply.find(@reply.id)
    @reply.agrees.should == 2
    @reply.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 2
    notification.names.map { |i| i.username }.should =~ [@member.username,@other_member_1.username]
    
    @reply.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @reply.is_agree_or_disagree(@other_member_1.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    
  end
  
  it "User agrees and unagrees, the notification should be deleted (1)" do

    agree_reply(@member,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    unagree_reply(@member,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    @reply = Reply.find(@reply.id)
    @reply.agrees.should == 0
    @reply.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.should be_nil
    
    unagree_notification = UnagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                                    :notified_member_id=>@other_member_0.id,
                                                                    :is_read=>false})
    unagree_notification.should be_nil
    
  end
  
  it "User agrees and unagrees, the notification should be deleted (2)" do

    agree_reply(@member,@reply.id)
    unagree_reply(@member,@reply.id)
    expect_and_perform_queue(:notification, 2)
    
    @reply = Reply.find(@reply.id)
    @reply.agrees.should == 0
    @reply.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                              :notified_member_id=>@other_member_0.id,
                                                              :is_read=>false})
    notification.should be_nil
    
    unagree_notification = UnagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                                    :notified_member_id=>@other_member_0.id,
                                                                    :is_read=>false})
    unagree_notification.should be_nil
    
  end
  
  it "should change agree to disagree and change the notification when user change his/her mind" do

    agree_reply(@member,@reply.id)
    disagree_reply(@member,@reply.id)
    expect_and_perform_queue(:notification, 2)
    
    @reply = Reply.find(@reply.id)
    @reply.agrees.should == 0
    @reply.disagrees.should == 1
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                              :notified_member_id=>@other_member_0.id,
                                                              :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@member.username]
    
    agree_notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                              :notified_member_id=>@other_member_0.id,
                                                              :is_read=>false})
    agree_notification.should be_nil
  end
  
  it "is agreed, read, then disagreed" do

    agree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                              :notified_member_id=>@other_member_0.id,
                                                              :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is agreed, read, then unagreed" do

    agree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)

    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    unagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = UnagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is disagreed, read, then unagreed" do

    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    unagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = UndisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is agreed, unagreed, then disagreed" do
    
    agree_reply(@other_member_1,@reply.id)
    unagree_reply(@other_member_1,@reply.id)
    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is agreed, unagreed, then agreed" do

    agree_reply(@other_member_1,@reply.id)
    unagree_reply(@other_member_1,@reply.id)
    agree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is disagreed, undisagreed, then agreed" do

    disagree_reply(@other_member_1,@reply.id)
    unagree_reply(@other_member_1,@reply.id)
    agree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is disagreed, undisagreed, then disagreed" do
 
    disagree_reply(@other_member_1,@reply.id)
    unagree_reply(@other_member_1,@reply.id)
    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
  it "is unagreed, then disagreed" do

    unagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 0)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.should be_nil
    
    disagree_reply(@other_member_1,@reply.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_id"=>@reply.id,
                                                          :notified_member_id=>@other_member_0.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_1.username]
    
  end
  
 
end