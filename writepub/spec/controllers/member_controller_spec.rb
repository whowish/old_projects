require 'spec_helper'

describe MemberController do
  include MemberRspecHelper
  
  before(:each) do
    @member = mock_member("Tanin","AAA")
  end
  
  it "logins successfully" do

    post :login, {:username=>"Tanin",
                  :password=>"AAA",
                  :redirect_url=>"/kratoo"
                  },
                  {:member_id=>nil}
                  
    body = expect_json_response
    body['ok'].should be_true
    body['redirect_url'].should == "/kratoo"   
    
  end
  
  
  it "logins failed" do

    post :login, {:username=>"Tanin",
                  :password=>"AAAB",
                  :redirect_url=>"/kratoo"
                  },
                  {:member_id=>nil}
                  
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['summary'].should == word_for(:login,:invalid)     
    
  end
  
  
end