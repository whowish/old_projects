# encoding: utf-8
require 'spec_helper'

describe 'ReplyOfReplyController' do
  
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include MemberRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin","AAA")
    @kratoo = mock_kratoo(@member, "Title", "Content")
    @reply = mock_reply(@member, @kratoo, "Content")
    @ror = mock_ror(@member, @reply, "ror content")
    commit_database
    
  end
  
  
  it "agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @ror.agrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:disagree_count,:number=>0))
    
  end

  it "agrees and unagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    
    click "reply_of_reply_unagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == ""
    @ror.agrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    
  end
  
  it "agrees and disagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @ror.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    
  end

  it "disagrees successfully" do

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @ror.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    
  end
  
  it "disagrees and undisagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    
    click "reply_of_reply_undisagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == ""
    @ror.disagrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:disagree_count,:number=>0))
    
  end
  
  it "disagrees and agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @ror = ReplyOfReply.find(@ror.id)
    @ror.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @ror.agrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:disagree_count,:number=>0))
  end
  
end