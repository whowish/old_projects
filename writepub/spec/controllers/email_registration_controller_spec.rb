require 'spec_helper'

describe EmailRegistrationController do
  
  before(:each) do
    
    @member = Member.create(:username=>"aniknun",:email=>"aniknun@nanakorn.com")
    @email_pending = EmailRegistrationPending.create(:email=>"funkky@nanakorn.com")
    @member_email_pending = EmailRegistrationPending.create(:email=>"aniknun@nanakorn.com")
    commit_database
  end
  
  it "register email successfully, the email is sent, fill in username/password, and everything is ok" do
    
    post :register, {:email=>"tanin@nanakorn.com"}
    
    body = expect_json_response
    body['ok'].should be_true
    expect_and_perform_queue(:normal, 1)
    
    email_pending = EmailRegistrationPending.where(:email=>"tanin@nanakorn.com").first
    email_pending.email.should == "tanin@nanakorn.com"
    
    post :create, {:email=>email_pending.email,
                     :unique_key=>email_pending._id,
                     :username=>"test",
                     :password=>"test_password"
                     }
    
    body = expect_json_response
    body['ok'].should be_true
    commit_database
    
    member = Member.where(:email=>"tanin@nanakorn.com").first
    member.email.should == "tanin@nanakorn.com"
    member.username.should == "test"
    
    require 'bcrypt'
    (BCrypt::Password.new(member.password) == "test_password").should be_true
    
    email_pending = EmailRegistrationPending.where(:email=>"tanin@nanakorn.com").first
    email_pending.should be_nil
    
  end
  
  it "register email successfully even the user submits it twice" do
    
    post :register, {:email=>"tanin@nanakorn.com"}
    
    body = expect_json_response
    body['ok'].should be_true
    commit_database
    
    expect_and_perform_queue(:normal, 1)
    
    email_pending = EmailRegistrationPending.where(:email=>"tanin@nanakorn.com").first
    email_pending.email.should == "tanin@nanakorn.com"
    
    key = email_pending._id
    
    # register again
    post :register, {:email=>"tanin@nanakorn.com"}
    
    body = expect_json_response
    body['ok'].should be_true
    commit_database
    
    expect_and_perform_queue(:normal, 1)
    
    email_pending = EmailRegistrationPending.where(:email=>"tanin@nanakorn.com").first
    email_pending.should_not be_nil
    email_pending.email.should == "tanin@nanakorn.com"
    email_pending._id.should == key
    
  end
  
  it "does not register an email when the email is already a member"  do
    
    post :register, {:email=>"aniknun@nanakorn.com"}
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['email'].should == word_for(:member,:email_uniqueness)

  end
  
  it "does not register username/password when the email is already a member" do
    
    post :create, {:email=>@member_email_pending.email,
                     :unique_key=>@member_email_pending._id,
                     :username=>"test",
                     :password=>"test"
                     }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['email'].should == word_for(:member,:email_uniqueness)
    
  end
  
  it "does not register username/password when record is invalid" do
    
    post :create, {:email=>@email_pending.email,
                     :unique_key=>"AA AA",
                     :username=>"test",
                     :password=>"test"
                     }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['summary'].should == word_for(:member,:invalid_record)
    
  end
  
  it "ensures unique username" do
    post :create, {:email=>@email_pending.email,
                     :unique_key=>@email_pending._id,
                     :username=>@member.username,
                     :password=>"test_pass"
                     }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['username'].should == word_for(:member,:username_uniqueness)
    
  end
  
  it "ensures unique username, even with different cases" do
    post :create, {:email=>@email_pending.email,
                     :unique_key=>@email_pending._id,
                     :username=>@member.username.upcase,
                     :password=>"test_pass"
                     }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['username'].should == word_for(:member,:username_uniqueness)
    
  end
  
  it "ensures unique email" do
    post :create, {:email=>@member.email,
                     :unique_key=>@email_pending._id,
                     :username=>"test",
                     :password=>"test_pass"
                     }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['email'].should == word_for(:member,:email_uniqueness)
  end
  
  it "does server side validation when registering" do
    post :register, {:email=>""}
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['email'].should =~ [word_for(:email_registration,:email_presence)]
    
    
    post :register, {:email=>"sgsdgsdgsdg"}
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['email'].should =~ [word_for(:email_registration,:email_email)]
    
  end
  
  it "does server side validation when creating" do
    
    post :create, {:email=>@email_pending.email,
                 :unique_key=>@email_pending._id,
                 :username=>"",
                 :password=>""
                 }
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['username'].should =~ [word_for(:member,:username_presence)]
    body['error_messages']['password'].should =~ [word_for(:member,:password_presence)]
    
  end
end
