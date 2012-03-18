# encoding: utf-8
require 'support/post_to_another_controller'
require 'support/login_rspec_helper'

module KratooRspecHelper
  include LoginRspecHelper
  
  def kratoo_login(username,password)
    fill 'kratoo_login_username', username
    fill 'kratoo_login_password', password
    click 'kratoo_login_button'
  end
  
  def member_integration_kratoo(title,content)
    
    fill 'kratoo_title', 'อั้มน่ารัก'
    fill 'kratoo_content',  "Test Content"
    click 'kratoo_submit_button'
    
  end
  
  def goto_kratoo_and_login(kratoo_id,username,password)
    
    goto "/kratoo/view/#{kratoo_id}"
    top_right_login(username, password)
    
    wait_for_ajax
    
    expect_path_to_be "/kratoo/view/#{kratoo_id}"
    
  end
  
  def mock_kratoo(member,title,content)
    kratoo = Kratoo.new
    kratoo.title = title
    kratoo.content = RichContent.new
    kratoo.content.set_html(content)
    kratoo.kratoo_type = Kratoo::TYPE_GENERAL
    kratoo.save
    kratoo.post_owner = PostOwner.create_object(kratoo,
                                                  member,
                                                  "",
                                                  "no",
                                                  "127.0.0.1")
                                                  
    kratoo.save
    
    return kratoo
  end
  
  def mock_anonymous_kratoo(member,title,content)
    kratoo = Kratoo.new
    kratoo.title = title
    kratoo.content = RichContent.new
    kratoo.content.set_html(content)
    kratoo.kratoo_type = Kratoo::TYPE_GENERAL
    kratoo.save
    kratoo.post_owner = PostOwner.create_object(kratoo,
                                                  member,
                                                  "#{member.username}_anonymous",
                                                  "yes",
                                                  "127.0.0.1")
                                                  
    kratoo.save
    
    return kratoo
  end
  
  def delete_kratoo(member,kratoo_id)
    wrap_with_controller(KratooController) do
      post :delete, {
                      :kratoo_id=>kratoo_id
                    },
                    mock_member_session(member)
    end

    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
                    
    body.should include('ok')
    body['ok'].should be_true
  end

  
  def member_read(member,kratoo_id)
    wrap_with_controller(KratooController) do
      post :view, {:id=>kratoo_id
                  },
                  mock_member_session(member)
    end
  end
  
  def member_create_kratoo(member,title,content,tags="A,B,C",type=Kratoo::TYPE_GENERAL)
    wrap_with_controller(KratooController) do
      post :add, {:title=>title,
                  :content=>content,
                  :kratoo_type=>type,
                  :tags=>tags
                  },
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)            
    body.should include('ok')

    return body['kratoo_id'] || nil
  end
  
  def anonymous_create_kratoo(member,username,title,content,tags="A,B,C")
    wrap_with_controller(KratooController) do
      post :add, {:title=>title,
                  :content=>content,
                  :kratoo_type=>Kratoo::TYPE_GENERAL,
                  :username=>username,
                  :is_anonymous=>"yes",
                  :tags=>tags
                  },
                  mock_member_session(member)
    end
                
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    body.should include('ok')
    
    return body['kratoo_id'] || nil
  end
  
  def agree_kratoo(member,kratoo_id)
    inner_agree_kratoo(member,kratoo_id,Kratoo::AGREEABLE_TYPE_AGREE)
  end
  
  def disagree_kratoo(member,kratoo_id)
    inner_agree_kratoo(member,kratoo_id,Kratoo::AGREEABLE_TYPE_DISAGREE)
  end
  
  def unagree_kratoo(member,kratoo_id)
    inner_agree_kratoo(member,kratoo_id,"")
  end
  
  private
    def inner_agree_kratoo(member,kratoo_id,agree_type)
      
      wrap_with_controller(KratooController) do
        post :agree, {:kratoo_id=>kratoo_id,
                      :agree_type=>agree_type
                      },
                      mock_member_session(member)
      end
                    
      response.should be_success
      body = ActiveSupport::JSON.decode(response.body)
      body.should include('ok')
      
    end
end