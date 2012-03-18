# encoding: utf-8
require 'spec_helper'

describe 'KratooController' do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include LoginRspecHelper
  
  before(:each) do
    
    @password = "AAA"
    @member = mock_member("Tanin","AAA",nil)
    @kratoo = mock_kratoo(@member,"Title","content")
    commit_database
    
  end
  
  it "agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @kratoo.agrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    
  end

  it "agrees and unagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    
    click 'kratoo_unagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == ""
    @kratoo.agrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:disagree_count,:number=>0))
    
  end
  
  it "agrees and disagrees successfully" do
     
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @kratoo.agrees.should == 0
    @kratoo.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    
  end

  it "disagrees successfully" do

    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_DISAGREE
    @kratoo.disagrees.should == 1
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
  end
  
  it "disagrees and undisagrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    
    click 'kratoo_undisagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == ""
    @kratoo.disagrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:agree_count,:number=>0))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_unagree.html.erb",:disagree_count,:number=>0))
  end
  
  it "disagrees and agrees successfully" do
    
    goto_kratoo_and_login(@kratoo.id,@member.username,@password)
    
    click 'kratoo_disagree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_disagree.html.erb",:disagree_count,:number=>1))
    
    click 'kratoo_agree_button'
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:disagree_count,:number=>0))
    commit_database
    
    @kratoo = Kratoo.find(@kratoo.id)
    @kratoo.is_agree_or_disagree(@member.id).should == Agreeable::AGREEABLE_TYPE_AGREE
    @kratoo.agrees.should == 1
    @kratoo.disagrees.should == 0
    
    goto "/kratoo/view/#{@kratoo.id}"
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:agree_count,:number=>1))
    expect_html_to_include('kratoo_agree_unit',word_for("kratoo/_agree.html.erb",:disagree_count,:number=>0))
    
  end
  
end