# encoding: utf-8
module ReplyOfReplyRspecHelper
  
  def reply_of_reply_login(username,password)
    fill 'reply_of_reply_login_username', username
    fill 'reply_of_reply_login_password', password
    click 'reply_of_reply_login_button'
    
  end
  
  def mock_ror(member,reply,content)
    
    commit_database
    
    ror = ReplyOfReply.new
    ror.reply_id = reply.id
    ror.content = RichContent.new
    ror.content.set_html(content)
    ror.created_date = Time.now
    
    ror.post_owner = PostOwner.create_object(reply.kratoo,
                                                member,
                                                "",
                                                "no",
                                                "127.0.0.1")
    ror.save
    
    kratoo = Kratoo.find(reply.kratoo.id)
    kratoo.all_reply_count += 1
    kratoo.save
    
    return ror
  end
  
  def delete_reply_of_reply(member,reply_of_reply_id)
    wrap_with_controller(ReplyOfReplyController) do
      post :delete, {
                      :reply_of_reply_id=>reply_of_reply_id
                    },
                    mock_member_session(member)
    end

    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
                    
    body.should include('ok')
  end
  
  def agree_reply_of_reply(member,reply_of_reply_id)
    inner_agree_reply_of_reply(member,reply_of_reply_id,Kratoo::AGREEABLE_TYPE_AGREE)
  end
  
  def disagree_reply_of_reply(member,reply_of_reply_id)
    inner_agree_reply_of_reply(member,reply_of_reply_id,Kratoo::AGREEABLE_TYPE_DISAGREE)
  end
  
  def unagree_reply_of_reply(member,reply_of_reply_id)
    inner_agree_reply_of_reply(member,reply_of_reply_id,"")
  end
  
  def member_integration_ror(reply,content)
    
    open_ror_dialog(reply)
    submit_ror_content(content)
    
  end
  
  def open_ror_dialog(reply)
    click "reply_reply_button_#{reply.id}"
    sleep(1)
  end
  
  def submit_ror_content(content)
    
    wait_until_present 'reply_of_reply_content'
    fill 'reply_of_reply_content', content
    
    click 'reply_of_reply_submit_button'
    wait_while_present 'reply_of_reply_submit_button'

    commit_database
    
  end
  
  def member_reply_of_reply(reply_id,member,content)
    
    wrap_with_controller(ReplyOfReplyController) do
      post :add, {:reply_id=>reply_id,
                  :content=>content},
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
                    
    body.should include('ok')
  end
  
  def anonymous_reply_of_reply(reply_id,member,username,content)
    wrap_with_controller(ReplyOfReplyController) do
      post :add, {:reply_id=>reply_id,
                  :username=>username,
                  :is_anonymous=>"yes",
                  :content=>content},
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
                    
    body.should include('ok')
  end
  
  
  private
  def inner_agree_reply_of_reply(member,reply_of_reply_id,agree_type)
    wrap_with_controller(ReplyOfReplyController) do
      post :agree, {:reply_of_reply_id=>reply_of_reply_id,
                    :agree_type=>agree_type
                    },
                    mock_member_session(member)
    end
                  
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
                    
    body.should include('ok')
  end
  
end