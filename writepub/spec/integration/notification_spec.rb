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
    
    @kratoo = mock_kratoo(@member, "TitleKratoo123", "Content")
    
    commit_database
  end
  
  it "notifies kratoo's owner, when someone replied" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    member_integration_reply("test reply")
    logout
    
    expect_and_perform_queue(:notification, 1)
    commit_database
    
    top_right_login("Tanin","AAA")
    
    html("notification_count_button").should include("1")
    html("notification_open_panel").should include(@kratoo.title)
    
  end
  
  it "notifies correctly when many replies are appied" do 
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    member_integration_reply("test reply")
    logout
    
    top_right_login("funkky", "CCC")
    member_integration_reply("test reply 2")
    logout
    
    expect_and_perform_queue(:notification, 2)
    commit_database
    
    top_right_login("aniknun","BBB")
    html("notification_count_button").should include("1")
    html("notification_open_panel").should include(@kratoo.title)
    logout
    
    top_right_login("Tanin","AAA")
    html("notification_count_button").should include("1")
    html("notification_open_panel").should include(@kratoo.title)

  end

  it "notifies correctly when a replied is replied" do
    
    @reply = mock_reply(@member, @kratoo, "Some Reply")
    
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    member_integration_ror(@reply,"test ror")
    logout
    
    top_right_login("funkky", "CCC")
    member_integration_ror(@reply,"test ror 2")
    logout
    
    expect_and_perform_queue(:notification, 2)
    commit_database
    
    top_right_login("aniknun","BBB")
    html("notification_count_button").should include("1")
    html("notification_open_panel").should include(@reply.content.text)
    logout
    
    top_right_login("Tanin","AAA")
    html("notification_count_button").should include("1")
    html("notification_open_panel").should include(@reply.content.text)

  end
  
  it "notifies correctly when kratoo is agreed and disagreed" do
  
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    logout
  
    top_right_login("funkky", "CCC")
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    logout
    
    expect_and_perform_queue(:notification, 2)
    commit_database
    
    top_right_login("Tanin","AAA")
    html("notification_count_button").should include("2")
    html("notification_open_panel").should include(@kratoo.title)   

  end

  it "notifies correctly when reply is agreed and disagreed" do
  
    @reply = mock_reply(@member, @kratoo, "Some Reply")
    commit_database
  
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    click "reply_agree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_agree.html.erb",:agree_count,:number=>1))
    logout
  
    top_right_login("funkky", "CCC")
    click "reply_disagree_button_#{@reply.id}"
    expect_html_to_include("reply_agree_unit_#{@reply.id}",word_for("reply/_disagree.html.erb",:disagree_count,:number=>1))
    logout
    
    expect_and_perform_queue(:notification, 2)
    commit_database
    
    top_right_login("Tanin","AAA")
    html("notification_count_button").should include("2")
    html("notification_open_panel").should include(@reply.content.text)   

  end

  it "notifies correctly when RoR is agreed and disagreed" do
  
    @reply = mock_reply(@member, @kratoo, "Some Reply")
    @ror = mock_ror(@member, @reply, "Some RoR")
    commit_database
  
    goto "/kratoo/view/#{@kratoo.id}"
    
    top_right_login("aniknun", "BBB")
    click "reply_of_reply_agree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_agree.html.erb",:agree_count,:number=>1))
    logout
  
    top_right_login("funkky", "CCC")
    click "reply_of_reply_disagree_button_#{@ror.id}"
    expect_html_to_include("reply_of_reply_agree_unit_#{@ror.id}", word_for("reply_of_reply/_disagree.html.erb",:disagree_count,:number=>1))
    logout
    
    expect_and_perform_queue(:notification, 2)
    commit_database
    
    top_right_login("Tanin","AAA")
    html("notification_count_button").should include("2")
    html("notification_open_panel").should include(@ror.content.text)   

  end
  
end

