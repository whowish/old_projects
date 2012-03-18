# encoding: utf-8
module ReplyRspecHelper
  
  def reply_login(username,password)
    fill 'reply_login_username', username
    fill 'reply_login_password', password
    click 'reply_login_button'
    
  end
  
  def mock_reply(member,kratoo,content)
    
    commit_database
    
    reply = Reply.new
    reply.kratoo_id = kratoo.id
    reply.content = RichContent.new
    reply.content.set_html(content)
    
    reply.post_owner = PostOwner.create_object(kratoo,
                                                member,
                                                "",
                                                "no",
                                                "127.0.0.1")
    reply.save
    
    kratoo = Kratoo.find(kratoo.id)
    kratoo.reply_count += 1
    kratoo.all_reply_count += 1
    kratoo.save
    
    return reply
  end
  
  def delete_reply(member,reply_id)
    wrap_with_controller(ReplyController) do
      post :delete, {
                    :reply_id=>reply_id
                    },
                    mock_member_session(member)
    end

    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    body.should include('ok')

  end
  
  def agree_reply(member,reply_id)
    inner_agree_reply(member,reply_id,Kratoo::AGREEABLE_TYPE_AGREE)
  end
  
  def disagree_reply(member,reply_id)
    inner_agree_reply(member,reply_id,Kratoo::AGREEABLE_TYPE_DISAGREE)
  end
  
  def unagree_reply(member,reply_id)
    inner_agree_reply(member,reply_id,"")
  end
  
  def member_integration_reply( content)
    
    fill 'reply_content', content
    click 'reply_submit_button'
    commit_database
    
  end
  
  def member_reply(kratoo_id,member,content)
    
    wrap_with_controller(ReplyController) do
      post :add, {:kratoo_id=>kratoo_id,
                  :content=>content
                  },
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    body.should include('ok')
    
    return body
  end
  
  def anonymous_reply(kratoo_id,member,username,content)
    wrap_with_controller(ReplyController) do
      post :add, {:kratoo_id=>kratoo_id,
                  :username=>username,
                  :is_anonymous=>"yes",
                  :content=>content
                  },
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    body.should include('ok')

    return body
  end
  
  
  private
    def inner_agree_reply(member,reply_id,agree_type)
      wrap_with_controller(ReplyController) do
        post :agree, {:reply_id=>reply_id,
                      :agree_type=>agree_type
                      },
                      mock_member_session(member)
      end
                    
      response.should be_success
      body = ActiveSupport::JSON.decode(response.body)
      body.should include('ok')

    end
end