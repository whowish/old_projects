require 'spec_helper'



describe KratooController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  
  before(:each) do
    
    26.times { |i|
      c = ("A"[0].ord+i).chr
      Tag.create(:_id=>c,:name=>c)
    }
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky","AAAC")
    commit_database
    
  end
  
  it "should increases the score of A and B, when posting Kratoo about A and B" do
    
    kratoo_id = member_create_kratoo(@member,"Title","Content","A,B")
    
    expect_and_perform_queue(:normal, 2)
    
    ContextWord.get_member("A",0,50).should =~ [@member.id.to_s]
    ContextWord.get_member("B",0,50).should =~ [@member.id.to_s]
    
    ContextWord.get_score(@member,"A").to_i.should == ContextWord::POST_SCORE
    ContextWord.get_score(@member,"B").to_i.should == ContextWord::POST_SCORE
    
  end
  
  it "should increases the score of A and B, when replying Kratoo about A and B" do
    
    kratoo_id = member_create_kratoo(@member,"Title","Content","A,B")
    member_reply(kratoo_id,@other_member_0,"ReplyContent1")
    member_reply(kratoo_id,@member,"ReplyContent2")
    
    expect_and_perform_queue(:normal, 6)
    
    ContextWord.get_member("A",0,50).should =~ [@member.id.to_s,@other_member_0.id.to_s]
    ContextWord.get_member("B",0,50).should =~ [@member.id.to_s,@other_member_0.id.to_s]
    
    ContextWord.get_score(@member,"A").to_i.should == (ContextWord::POST_SCORE + ContextWord::REPLY_SCORE)
    ContextWord.get_score(@member,"B").to_i.should == (ContextWord::POST_SCORE + ContextWord::REPLY_SCORE)
    
    ContextWord.get_score(@other_member_0,"A").to_i.should == ContextWord::REPLY_SCORE
    ContextWord.get_score(@other_member_0,"B").to_i.should == ContextWord::REPLY_SCORE
  end
  
  it "should increases the score of A and B, when reading Kratoo about A and B, and there is no effect when reading twice" do
    kratoo_id = member_create_kratoo(@member,"Title","Content","A,B")
    member_reply(kratoo_id,@other_member_0,"ReplyContent1")
    
    member_read(@other_member_0,kratoo_id)
    member_read(@member,kratoo_id)
    
    member_read(@other_member_0,kratoo_id)
    member_read(@member,kratoo_id)
    
    expect_and_perform_queue(:normal, 6)
    
    ContextWord.get_member("A",0,50).should =~ [@member.id.to_s,@other_member_0.id.to_s]
    ContextWord.get_member("B",0,50).should =~ [@member.id.to_s,@other_member_0.id.to_s]
    
    ContextWord.get_score(@member,"A").to_i.should == (ContextWord::POST_SCORE + ContextWord::READ_SCORE)
    ContextWord.get_score(@member,"B").to_i.should == (ContextWord::POST_SCORE + ContextWord::READ_SCORE)
    
    ContextWord.get_score(@other_member_0,"A").to_i.should == (ContextWord::REPLY_SCORE + ContextWord::READ_SCORE)
    ContextWord.get_score(@other_member_0,"B").to_i.should == (ContextWord::REPLY_SCORE + ContextWord::READ_SCORE)
  end
  
  it "should distribute Kratoo correctly, with A and B is valid, while C is underranked, and D is not in the list" do

    KratooDistributor::MAX_RANK = 2
    MemberFeed::KRATOO_IN_FEED = 2 
    
    kratoo = Kratoo.new
    kratoo.context_words = ["C"]
    ContextWord.member_post(@member,kratoo)
    
    kratoo.context_words = ["A","B"]
    ContextWord.member_post(@member,kratoo)
    ContextWord.member_reply(@member,kratoo)
    
    commit_database
    
    kratoo_id_0 = member_create_kratoo(@other_member_0,"Title","Content","A,B")
    kratoo_id_1 = member_create_kratoo(@other_member_0,"Title","Content","C")
    kratoo_id_2 = member_create_kratoo(@other_member_0,"Title","Content","A,B")
    kratoo_id_3 = member_create_kratoo(@other_member_0,"Title","Content","A,B")
    
    member_read(@other_member_0,kratoo_id_3)
    member_read(@other_member_1,kratoo_id_3)
    
    member_read(@other_member_1,kratoo_id_1)
    
    expect_and_perform_queue(:normal, 11)

    feed = MemberFeed.new(@member.id)
    feed.get_feed.map{|i| i.id.to_s}.should =~ [kratoo_id_1,kratoo_id_3]
    
  end
  
  it "read twice and 10 minutes apart, it should count as 1" do
    
    kratoo_id = member_create_kratoo(@member,"Title","Content","A,B")

    member_read(@other_member_0,kratoo_id)
    
    next_time = Time.now + 10*60 + 10
    Time.stub!(:now).and_return(next_time)
    
    member_read(@other_member_0,kratoo_id)
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.views.should == 1
    
  end
  
  it "read twice and 40 minutes apart, it should count as 2" do
    
    kratoo_id = member_create_kratoo(@member,"Title","Content","A,B")

    member_read(@other_member_0,kratoo_id)
    
    next_time = Time.now + 40*60 + 10
    Time.stub!(:now).and_return(next_time)
    
    member_read(@other_member_0,kratoo_id)
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.views.should == 2
    
  end
end