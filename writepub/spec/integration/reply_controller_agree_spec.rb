# encoding: utf-8
require 'spec_helper'

describe 'ReplyController' do
  
  include KratooRspecHelper
  include ReplyRspecHelper
  include LoginRspecHelper
  include MemberRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin",@password)
    @kratoo = mock_kratoo(@member, "Title", "content")
    @reply = mock_reply(@member, @kratoo, "reply content")
    commit_database
    
  end
  

  it "agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_unagree_button_#{@reply.id}")
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @reply.agrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_unagree_button_#{@reply.id}")
    
  end

  it "agrees and unagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    
    click "reply_unagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == ""
    @reply.agrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    
  end
  
  it "agrees and disagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_undisagree_button_#{@reply.id}")
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @reply.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_undisagree_button_#{@reply.id}")
    
  end

  it "disagrees successfully" do

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @reply.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
  end
  
  it "disagrees and undisagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
    
    click "reply_undisagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == ""
    @reply.disagrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_agree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    
  end
  
  it "disagrees and agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
    
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_unagree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    commit_database
    
    @reply = Reply.find(@reply.id)
    @reply.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @reply.agrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_unagree_button_#{@reply.id}")
    expect_html_to_include("reply_agree_unit_#{@reply.id}","reply_disagree_button_#{@reply.id}")
    
  end
end