# encoding: utf-8
require 'spec_helper'

describe 'Notification' do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include LoginRspecHelper
  include FacebookConnectRspecHelper
  
  before(:each) do
    @member = mock_member("Tanin","AAA")
    @other_member = mock_member("Aniknun","BBB")
    @other_member_1 = mock_member("Funkky","CCC")
    
    commit_database
  end
  
  it "posts kratoo" do

    goto '/kratoo'
  
    top_right_login("Tanin", "AAA")
    member_integration_kratoo("title","content")
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    kratoo = Kratoo.first
    html("member_action_list_panel").should include(word_for("profile/_activity_create_kratoo_item.html.erb",:activity_create_kratoo,:content=>kratoo.title,:url=>"/kratoo/view/#{kratoo.id}"))

  end
  
  it "replies kratoo" do
 
    @kratoo = mock_kratoo(@member, "TitleKratoo123", "Content")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    member_integration_reply("reply1234")
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    reply = Reply.first
    html("member_action_list_panel").should include(word_for("profile/_activity_reply_item.html.erb",:activity_reply_kratoo,:content=>reply.content.text,:url=>"/kratoo/view/#{reply.kratoo_id}"))

  end
  
  it "replies reply" do
    
    @kratoo = mock_kratoo(@member, "TitleKratoo123", "Content")
    @reply = mock_reply(@member, @kratoo, "Reply1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    member_integration_ror(@reply,"reply1234")
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    ror = ReplyOfReply.first
    html("member_action_list_panel").should include(word_for("profile/_activity_reply_item.html.erb",:activity_reply_kratoo,:content=>ror.content.text,:url=>"/kratoo/view/#{ror.reply.kratoo_id}"))

  end
  
  it "agrees kratoo" do

    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_love_item.html.erb",:activity_love_kratoo,:content=>@kratoo.title,:url=>"/kratoo/view/#{@kratoo.id}"))
   
  end
 
   
  it "disagrees kratoo" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_hate_item.html.erb",:activity_hate_kratoo,:content=>@kratoo.title,:url=>"/kratoo/view/#{@kratoo.id}"))
   
  end
  
  it "agrees reply" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
   
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@reply.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end

  it "disagrees reply" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
   
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_disagree_item.html.erb",:activity_disagree_item,:content=>@reply.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "agrees ror" do
   
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    @ror = mock_ror(@other_member, @reply, "RoR1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@ror.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end

  it "disagrees ror" do

    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    @ror = mock_ror(@other_member, @reply, "RoR1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should include(word_for("profile/_activity_disagree_item.html.erb",:activity_disagree_item,:content=>@ror.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "unagrees kratoo (previously agree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    click 'kratoo_unagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:agree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should_not include(word_for("profile/_activity_love_item.html.erb",:activity_love_kratoo,:content=>@kratoo.title,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "unagrees reply (previously agree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "reply1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
 
    click "reply_unagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    html("member_action_list_panel").should_not include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@reply.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "unagrees ror (previously agree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    @ror = mock_ror(@other_member, @reply, "RoR1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    click "reply_of_reply_unagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:agree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    html("member_action_list_panel").should_not include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@ror.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end

  it "unagrees kratoo (previously disagree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    click 'kratoo_undisagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:disagree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    
    html("member_action_list_panel").should_not include(word_for("profile/_activity_love_item.html.erb",:activity_love_kratoo,:content=>@kratoo.title,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "unagrees reply (previously agree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "reply1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
 
    click "reply_undisagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_unagree.html.erb",:disagree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    html("member_action_list_panel").should_not include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@reply.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
  
  it "unagrees ror (previously agree)" do
    
    @kratoo = mock_kratoo(@other_member, "TitleKratoo123", "Content")
    @reply = mock_reply(@other_member, @kratoo, "Reply1234")
    @ror = mock_ror(@other_member, @reply, "RoR1234")
    commit_database
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("Tanin", "AAA")
    
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    click "reply_of_reply_undisagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_unagree.html.erb",:disagree_count,:number=>0))
    expect_and_perform_queue(:member_action, 1)
    commit_database
    
    goto "/profile/#{@member.id}"
    html("member_action_list_panel").should_not include(word_for("profile/_activity_agree_item.html.erb",:activity_agree_item,:content=>@ror.content.text,:url=>"/kratoo/view/#{@kratoo.id}"))
  
  end
 
end