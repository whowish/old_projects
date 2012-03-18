require 'spec_helper'

describe Kratoo do
  
  before(:each) do
    @member = Member.create(:username=>"aaa",:password=>"aaa")
    @member_1 = Member.create(:username=>"asd",:password=>"asd")

    @kratoo = Kratoo.create(:title=>"Adsad",:kratoo_type=>Kratoo::TYPE_GENERAL,:created_date=>Time.now)
  
    
  end
  
  it "save anonymous name, and get anonyname correctly" do
    @kratoo.set_anonymous_name(@member,"test")
    @kratoo.set_anonymous_name(@member_1,"test2")
    
    @kratoo.get_anonymous_name(@member).should == "test"
    @kratoo.get_anonymous_name(@member_1).should == "test2"
     
  end
  
  it "verifies that user uses public name" do 
    @kratoo.set_anonymous_name(@member,"test")
    
    @kratoo.is_set_anonymous_name(@member).should == true
    @kratoo.is_set_anonymous_name(@member_1).should == false
  end
  
  it "verifies that user uses anonymous name" do
    @kratoo.set_anonymous_name(@member,"test")
    @kratoo.is_set_anonymous_name(@member).should == true
    @kratoo.get_anonymous_name(@member).should == "test"
  end
  
  it "verifies that user never posted before" do 
    @kratoo.is_set_kratoo_member(@member).should == false
    @kratoo.set_kratoo_member(@member,"OwnerPublic")
    @kratoo.is_set_kratoo_member(@member).should == true
  end
  
  it "does not conflict between 2 users (both anonymous)" do 
    @kratoo.set_anonymous_name(@member,"test")
    @kratoo.set_anonymous_name(@member_1,"test2")
    
    @kratoo.set_kratoo_member(@member,"OwnerAnonymous")
    @kratoo.set_kratoo_member(@member_1,"OwnerAnonymous")
    
    @kratoo.get_anonymous_name(@member).should == "test"
    @kratoo.get_anonymous_name(@member_1).should == "test2"
    
    @kratoo.is_used_anonymous_name("test").should == true
    @kratoo.is_used_anonymous_name("test2").should == true
    @kratoo.is_used_anonymous_name("test3").should == false
    
    @kratoo.is_set_kratoo_member(@member).should == true
    @kratoo.is_set_kratoo_member(@member_1).should == true
  end
  
  it "does not condflict between 2 users (one anonymous, another public)" do
    @kratoo.set_anonymous_name(@member,"test")
    
    @kratoo.set_kratoo_member(@member,"OwnerAnonymous")
    @kratoo.set_kratoo_member(@member_1,"OwnerPublic")
    
    @kratoo.get_anonymous_name(@member).should == "test"
    
    @kratoo.is_used_anonymous_name("test").should == true
    @kratoo.is_used_anonymous_name("test2").should == false
    
    @kratoo.is_set_kratoo_member(@member).should == true
    @kratoo.is_set_kratoo_member(@member_1).should == true
    
    @kratoo.get_anonymous_name(@member_1).should be_nil
  end
  
  it "verifies that the name has been used by somebody else" do
    @kratoo.set_anonymous_name(@member,"test")
    @kratoo.set_anonymous_name(@member_1,"test")

    @kratoo.get_anonymous_name(@member).should == "test"
    @kratoo.get_anonymous_name(@member_1).should be_nil
    
    @kratoo.is_used_anonymous_name("test").should == true
    @kratoo.is_set_anonymous_name(@member).should == true
    @kratoo.is_set_anonymous_name(@member_1).should == false
    
  end
  
end
  