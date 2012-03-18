require 'spec_helper'



describe KratooController do
  
  include MemberRspecHelper
  include KratooRspecHelper
  include ReplyRspecHelper
  include ReplyOfReplyRspecHelper
  include NotificationRspecHelper
  include MemberActionRspecHelper
  
  before(:each) do
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>[],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["C"],:incomings=>[])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>[],:incomings=>["B"])
    
    @member = mock_member("Tanin", "AAA")
    @other_member_0 = mock_member("Aniknun", "AAAB")
    @other_member_1 = mock_member("Funkky", "AAAC")
    commit_database
    
  end

  it "is created by a guest (not allowed)" do
    
    
    post :add, {:title=>"TestTitle",
                    :content=>"Hello World",
                    :kratoo_type=>Kratoo::TYPE_GENERAL,
                    :username=>"This is a guest",
                    :tags=>"A,B,C"
                    } ,
                    {:member_id=>nil}

    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['summary'].should == word_for(:kratoo,:do_not_allow_guest)
    
  end
  
  it "is created by a member, who agrees to share his name" do
    
    member_create_kratoo(@member,"TestTitle","Hello World","A,B,C")

    body = expect_json_response
    body['ok'].should be_true
    
    kratoo_id = body['kratoo_id']
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.all_tag_ids.should =~ ["A","B","C"]
    kratoo.tag_ids.should =~ ["A","C"]
    
    kratoo.title.should == "TestTitle"
    kratoo.content.text.should == "Hello World"
    kratoo.kratoo_type.should == Kratoo::TYPE_GENERAL
    
    kratoo.post_owner.should be_an_instance_of(OwnerPublic)
    kratoo.post_owner.username.should == @member.username
    
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ []
    
  end

  it "is created by a member, who hides his name" do
    
    anonymous_create_kratoo(@member,"TaninHidden","TestTitle","Hello World","A,B,C")

    body = expect_json_response
    body['ok'].should be_true
    
    kratoo_id = body['kratoo_id']
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.all_tag_ids.should =~ ["A","B","C"]
    kratoo.tag_ids.should =~ ["A","C"]
    
    kratoo.title.should == "TestTitle"
    kratoo.content.text.should == "Hello World"
    kratoo.kratoo_type.should == Kratoo::TYPE_GENERAL
    
    kratoo.post_owner.should be_an_instance_of(OwnerAnonymous)
    kratoo.post_owner.username.should == "TaninHidden"
    
    kratoo.get_anonymous_name(@member).should == "TaninHidden"
    kratoo.is_anonymous_name_used("TaninHidden").should == true
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ ["TaninHidden"]
    
  end
  

  it "does server validation" do

    member_create_kratoo(@member,"   "," ","A,B,C","some type")

    body = expect_json_response
    body['ok'].should be_false
    
    body['error_messages']['title'].should =~ [word_for(:kratoo,:title_presence)]
    body['error_messages']['content'].should =~ [word_for(:kratoo,:content_presence)]
    body['error_messages']['kratoo_type'].should =~ [word_for(:kratoo,:kratoo_type_check_type)]
    
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ []
    
    
    long_content = ""
    300.times { long_content << "a" }
    member_create_kratoo(@member, long_content, " ", "A,B,C","some type")
    
    body = expect_json_response
    body['ok'].should be_false
    
    body['error_messages']['title'].should =~ [word_for(:kratoo,:title_max_length)]
    body['error_messages']['content'].should =~ [word_for(:kratoo,:content_presence)]
    body['error_messages']['kratoo_type'].should =~ [word_for(:kratoo,:kratoo_type_check_type)]
    
    $redis.smembers(kratoo.redis_anonymous_names).should  =~ []
    
  end
  
  it "logins before posting kratoo" do
    
    wrap_with_controller(MemberController) do
      post :login, {:username=>"tanin",
                    :password=>"AAA",
                    :option=>"receiver_kratoo"
                  } ,
                  {:member_id=>nil}
    end
    
    body = expect_json_response
    body.should include('kratoo_identity_panel')
    
  end
  
  it "validates login before posting kratoo (server-side)" do
    
    wrap_with_controller(MemberController) do
      post :login, {:username=>"tanin",
                    :password=>"AAAABS"
                  } ,
                  {:member_id=>nil}
    end
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_messages']['summary'].should == word_for(:login,:invalid)
    
  end
  
  it "is edited by a member" do
   
   kratoo_id = member_create_kratoo(@member,"Title","Content")
   
    post :edit_kratoo, {:title=>"EditTitle",
                        :content=>"Hello World2",
                        :kratoo_id=>kratoo_id
                        
                        },
                        mock_member_session(@member)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    kratoo_id = body['kratoo_id']
    
    commit_database
    
    kratoo = Kratoo.find(kratoo_id)
    kratoo.all_tag_ids.should =~ ["A","B","C"]
    kratoo.tag_ids.should =~ ["A","C"]
    
    kratoo.title.should == "EditTitle"
    kratoo.content.text.should == "Hello World2"
    kratoo.kratoo_type.should == Kratoo::TYPE_GENERAL
    
    kratoo.post_owner.should be_an_instance_of(OwnerPublic)
    kratoo.post_owner.username.should == @member.username
    
    versioning_kratoo = VersioningKratoo.all(:conditions=>{:kratoo_id=>kratoo_id})
    versioning_kratoo.count.should == 2
    
  end 
  
  it "is deleted by a member" do
   
    kratoo_id = member_create_kratoo(@member,"Title","Content")

    post :delete, {
                :kratoo_id=>kratoo_id
                },
                mock_member_session(@member)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    commit_database
  
    deleted_kratoo = DeletedKratoo.first(:conditions=>{:kratoo_id=>kratoo_id})
    deleted_kratoo.deleted_member_id.to_s.should == @member.id.to_s
    
    deleted_kratoo.object_data.should be_an_instance_of(Kratoo)
    
    kratoo = Kratoo.first(:conditions=>{:id=>kratoo_id})
    kratoo.should be_nil
    
  end 
  
  it "is deleted by a member with reply and reply of reply" do

    kratoo = mock_kratoo(@member, "Title", "Content")
    reply = mock_reply(@member, kratoo, "Reply")
    ror = mock_ror(@member, reply, "RoR")
    commit_database
   
    post :delete, {
                :kratoo_id=>kratoo.id
                },
                mock_member_session(@member)
                    
    body = expect_json_response
    body['ok'].should be_true
    
    commit_database
    
    expect_and_perform_queue(:normal, 1)
    commit_database
    
    deleted_objects = DeletedObject.all
    deleted_objects.count.should == 3
  
    deleted_kratoo = DeletedKratoo.first(:conditions=>{:kratoo_id=>kratoo.id})
    deleted_kratoo.deleted_member_id.to_s.should == @member.id.to_s
    deleted_kratoo.object_data.should be_an_instance_of(Kratoo)
    
    deleted_reply = DeletedReply.first(:conditions=>{:reply_id=>reply.id})
    deleted_reply.deleted_member_id.to_s.should == @member.id.to_s
    deleted_reply.object_data.should be_an_instance_of(Reply)
    
    deleted_ror = DeletedReplyOfReply.first(:conditions=>{:reply_of_reply_id=>ror.id})
    deleted_ror.deleted_member_id.to_s.should == @member.id.to_s
    deleted_ror.object_data.should be_an_instance_of(ReplyOfReply)
    
    
    kratoo = Kratoo.first(:conditions=>{:id=>kratoo.id})
    kratoo.should be_nil
    
    reply = Reply.first(:conditions=>{:id=>reply.id})
    reply.should be_nil
    
    ror = ReplyOfReply.first(:conditions=>{:id=>ror.id})
    ror.should be_nil
    
  end 
  
  it "is read by a member" do
    kratoo_id = member_create_kratoo(@member,"Title","Content")
    
    post :view, {
                :id=>kratoo_id
                },
                mock_member_session(@member)
                
    kratoo = Kratoo.first(:conditions=>{:id=>kratoo_id})            
    kratoo.is_read(@member.id).should == true
    $redis.zscore(kratoo.redis_read_key,@member.id).should_not be_nil
  end
  
  it "is deleted by a member with notification and member action" do
  
   @kratoo = mock_kratoo(@member,"Title","Content")
   @reply = mock_reply(@other_member_0,@kratoo, "replyContent")
   @ror = mock_ror(@other_member_1, @reply, "RoR content")
   
   kratoo_agree_notification_entity = KratooAgreeableEntity.new(:kratoo_id=>@kratoo.id,:content=>@kratoo.title)
   @kratoo_agree_notification = mock_agree_notification(@member, "kratoo_agree", @ror.post_owner, kratoo_agree_notification_entity)
   
   reply_agree_notification_entity = ReplyAgreeableEntity.new(:reply_id=>@reply.id,:content=>@reply.content.text)
   @reply_agree_notification = mock_agree_notification(@member, "reply_agree", @ror.post_owner, reply_agree_notification_entity)
   
   ror_agree_notification_entity = ReplyOfReplyAgreeableEntity.new(:reply_of_reply_id=>@ror.id,:content=>@ror.content.text)
   @ror_agree_notification = mock_agree_notification(@member, "ror_agree", @ror.post_owner, ror_agree_notification_entity)
   
   @reply_notification = mock_reply_notification(@member , @reply)
   @ror_notification = mock_ror_notification(@member , @ror)
   
   
   kratoo_member_action_entity = KratooActionEntity.new(:kratoo_id=>@kratoo.id,:content=>@kratoo.title)
   @kratoo_member_action =  mock_member_action(@member,kratoo_member_action_entity)
   
   reply_member_action_entity = ReplyActionEntity.new(:reply_id=>@reply.id,:content=>@reply.content.text,:kratoo_id=>@kratoo.id)
   @reply_member_action =  mock_member_action(@member,reply_member_action_entity)
   
   ror_member_action_entity = ReplyOfReplyActionEntity.new(:content=>@reply.content.text,:kratoo_id=>@kratoo.id,:reply_of_reply_id=>@ror.id)
   @ror_member_action =  mock_member_action(@member,ror_member_action_entity)
   
    post :delete, {
                :kratoo_id=>@kratoo.id
                },
                mock_member_session(@member)
                    
    body = expect_json_response
    body['ok'].should be_true
    commit_database
    
    expect_and_perform_queue(:normal, 1)
    commit_database
    
    deleted_objects = DeletedObject.all()
    deleted_objects.count.should == 3
  
    deleted_kratoo = DeletedKratoo.first(:conditions=>{:kratoo_id=>@kratoo.id})
    deleted_kratoo.deleted_member_id.to_s.should == @member.id.to_s
    deleted_kratoo.object_data.should be_an_instance_of(Kratoo)
    
    deleted_reply = DeletedReply.first(:conditions=>{:reply_id=>@reply.id})
    deleted_reply.deleted_member_id.to_s.should == @member.id.to_s
    deleted_reply.object_data.should be_an_instance_of(Reply)
    
    deleted_r_o_r = DeletedReplyOfReply.first(:conditions=>{:reply_of_reply_id=>@ror.id})
    deleted_r_o_r.deleted_member_id.to_s.should == @member.id.to_s
    deleted_r_o_r.object_data.should be_an_instance_of(ReplyOfReply)
    
    
    kratoo = Kratoo.first(:conditions=>{:id=>@kratoo.id})
    kratoo.should be_nil
    
    reply = Reply.first(:conditions=>{:id=>@reply.id})
    reply.should be_nil
    
    r_o_r = ReplyOfReply.first(:conditions=>{:id=>@ror.id})
    r_o_r.should be_nil
    
    kratoo_agree_notification = AgreeableNotification.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id})
    kratoo_agree_notification.should be_nil
    reply_agree_notification = AgreeableNotification.first(:conditions=>{"entity.reply_id"=>@reply.id})
    reply_agree_notification.should be_nil
    ror_agree_notification = AgreeableNotification.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id})
    ror_agree_notification.should be_nil
    
    reply_notification = ReplyNotification.first(:conditions=>{:reply_id=>@reply.id})
    reply_notification.should be_nil
    
    ror_notification = ReplyOfReplyNotification.first(:conditions=>{:reply_of_reply_id=>@ror.id})
    ror_notification.should be_nil
    
    kratoo_member_action = MemberAction.first(:conditions=>{"entity.kratoo_id"=>@kratoo.id})
    kratoo_member_action.should be_nil
    reply_member_action = MemberAction.first(:conditions=>{"entity.reply_id"=>@reply.id})
    reply_member_action.should be_nil
    ror_member_action = MemberAction.first(:conditions=>{"entity.reply_of_reply_id"=>@ror.id})
    ror_member_action.should be_nil
    
  end 
  
end