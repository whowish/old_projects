require 'spec_helper'

describe ReplyOfReplyController do
  
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
    
    @kratoo = mock_kratoo(@member, "Title", "Content")
    @reply = mock_reply(@other_member_0, @kratoo, "reply content")
    @ror = mock_ror(@other_member_1, @reply, "RoR content")
    
    commit_database
    
  end
  
  it "is liked (by one) and disliked (by another) and should notify the post's owner correctly" do
    
    agree_reply_of_reply(@member,@ror.id)
    disagree_reply_of_reply(@other_member_0,@ror.id)
    disagree_reply_of_reply(@other_member_1,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.agrees.should == 1
    @ror.disagrees.should == 2
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    
    notification.count.should == 1
    notification.names.map { |i| i.username}.should =~ [@member.username]
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    
    notification.count.should == 1
    notification.names.map { |i| i.username}.should =~ [@other_member_0.username]
    
  end
  
  it "First user likes and likes, Second user dislikes and likes" do

    agree_reply_of_reply(@member,@ror.id)
    agree_reply_of_reply(@member,@ror.id)
    disagree_reply_of_reply(@other_member_0,@ror.id)
    agree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.agrees.should == 2
    @ror.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.count.should == 2
    notification.names.map { |i| i.username}.should =~ [@member.username,@other_member_0.username]
    
    @ror.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @ror.is_agree_or_disagree(@other_member_0.id).should == Agreeable::AGREEABLE_TYPE_AGREE
  end
  
  it "User agrees and unagrees, the notification should be deleted(1)" do

    agree_reply_of_reply(@member,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    unagree_reply_of_reply(@member,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.agrees.should == 0
    @ror.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.should be_nil
    
    unagree_notification = UnagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    unagree_notification.should be_nil
    
  end
  
  it "User agrees and unagrees, the notification should be deleted(2)" do

    agree_reply_of_reply(@member,@ror.id)
    unagree_reply_of_reply(@member,@ror.id)
    expect_and_perform_queue(:notification, 2)
    
    # commit all changes
    Mongoid.database.command({:getlasterror => 1, :fsync=>true})
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.agrees.should == 0
    @ror.disagrees.should == 0
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.should be_nil
    
    unagree_notification = UnagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                                    :notified_member_id=>@other_member_1.id,
                                                                    :is_read=>false})
    unagree_notification.should be_nil
    
  end
  
  it "should change agree to disagree and change the notification when user change his/her mind" do
    
    agree_reply_of_reply(@member,@ror.id)
    disagree_reply_of_reply(@member,@ror.id)
    expect_and_perform_queue(:notification, 2)
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.agrees.should == 0
    @ror.disagrees.should == 1
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                            :notified_member_id=>@other_member_1.id,
                                                            :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username}.should =~ [@member.username]
    
    agree_notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                                :notified_member_id=>@other_member_1.id,
                                                                :is_read=>false})
    agree_notification.should be_nil
    
  end
  
  it "is agreed, read, then disagreed" do

    agree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    disagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification =DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
    agree_notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                                :notified_member_id=>@other_member_1.id,
                                                                :is_read=>false})
    agree_notification.should be_nil
    
  end
  
  it "is agreed, read, then unagreed" do

    agree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    unagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = UnagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
  
  it "is disagreed, read, then unagreed" do

    disagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
  
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.is_read = true
    notification.save
    commit_database
    
    unagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = UndisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                              :notified_member_id=>@other_member_1.id,
                                                              :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
  
  it "is agreed, unagreed, then disagreed" do

    agree_reply_of_reply(@other_member_0,@ror.id)
    unagree_reply_of_reply(@other_member_0,@ror.id)
    disagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                            :notified_member_id=>@other_member_1.id,
                                                            :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
  
  it "is agreed, unagreed, then agreed" do
   
    agree_reply_of_reply(@other_member_0,@ror.id)
    unagree_reply_of_reply(@other_member_0,@ror.id)
    agree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
  
  it "is disagreed, undisagreed, then agreed" do
 
    disagree_reply_of_reply(@other_member_0,@ror.id)
    unagree_reply_of_reply(@other_member_0,@ror.id)
    agree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = AgreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                          :notified_member_id=>@other_member_1.id,
                                                          :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
  
  it "is disagreed, undisagreed, then disagreed" do

    disagree_reply_of_reply(@other_member_0,@ror.id)
    unagree_reply_of_reply(@other_member_0,@ror.id)
    disagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 3)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                            :notified_member_id=>@other_member_1.id,
                                                            :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
  end
  
  it "is unagreed, then disagreed" do
    
    unagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 0)
    
    notification = UnagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                            :notified_member_id=>@other_member_1.id,
                                                            :is_read=>false})
    notification.should be_nil
    
    disagree_reply_of_reply(@other_member_0,@ror.id)
    expect_and_perform_queue(:notification, 1)
    
    notification = DisagreeNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id,
                                                            :notified_member_id=>@other_member_1.id,
                                                            :is_read=>false})
    notification.count.should == 1
    notification.names.map { |i| i.username }.should =~ [@other_member_0.username]
    
  end
end