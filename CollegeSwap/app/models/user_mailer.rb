class UserMailer < ActionMailer::Base
  include FacebookHelper
  include ItemHelper
  include ApplicationHelper
  
  def request_swap(request)   
    @request = request
    responder_item = Item.first(:conditions=>{:id=> @request.responder_item_id})
    requestor_item = Item.first(:conditions=>{:id=> @request.requestor_item_id})
    @responder = get_facebook_info(request.responder_facebook_id)
    @requestor = get_facebook_info(request.requestor_facebook_id)
    @title = "You've got a swap request from " + @requestor.name + " on your trade post: "
    @title += responder_item.title + " with " + get_possessive_adj(@requestor).downcase + " "+  requestor_item.title+ "."
    
    if requestor_item.is_money == 1
      @title = "You've got a swap request from " + @requestor.name + " on your trade post: "
      @title += responder_item.title + " for " +  requestor_item.title + "."
    end
    
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/inbox"
    recipients @responder.email
    content_type "text/html" 
    from "College Swap <whowish@gmail.com>" 
    subject "You've got a swap request!"
    sent_on Time.now 
  end
  
  def response_swap_accept(request)  
    @request = request
    responder_item = Item.first(:conditions=>{:id=> @request.responder_item_id})
    requestor_item = Item.first(:conditions=>{:id=> @request.requestor_item_id})
    @responder = get_facebook_info(request.responder_facebook_id)
    @requestor = get_facebook_info(request.requestor_facebook_id)
    @title = "Congrats! Your swap is accepted. " + @responder.name + " accepted to swap your "
    @title += requestor_item.title + " with " + get_possessive_adj(@responder).downcase + " "+  responder_item.title+ "."
    
    if requestor_item.is_money == 1
      @title = "Congrats! Your swap is accepted. " + @responder.name + " accepted to sell "
      @title += get_possessive_adj(@responder).downcase + " "+  responder_item.title+ " for " + requestor_item.title + "."
    end
    
    @url = "http://www.facebook.com/profile.php?id=" + @responder.facebook_id
    content_type "text/html" 
    recipients @requestor.email
    from "College Swap <whowish@gmail.com>" 
    subject "Congrats! Your swap is accepted."
    sent_on Time.now 
   
  end
  
  def response_swap_reject(request)   
    @request = request
    responder_item = Item.first(:conditions=>{:id=> @request.responder_item_id})
    requestor_item = Item.first(:conditions=>{:id=> @request.requestor_item_id})
    @responder = get_facebook_info(request.responder_facebook_id)
    @requestor = get_facebook_info(request.requestor_facebook_id)
    @title = "Sorry, your swap was not accepted. " + @responder.name + " rejected to swap your "
    @title += requestor_item.title + " with " + get_possessive_adj(@responder).downcase + " "+  responder_item.title+ "."
    
    if requestor_item.is_money == 1
      @title = "Sorry, your swap was not accepted. " + @responder.name + " rejected to sell "
      @title += get_possessive_adj(@responder).downcase + " "+  responder_item.title+ " for " + requestor_item.title + "."
    end
    
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME
    @suggest_wish = get_suggest_item(@requestor,5)
    
    @suggest_wish.each {|w|
      w_owner = get_facebook_info(w.facebook_id)
      w[:name] = w_owner.name
      w[:college_name] = get_college_name_of(w.facebook_id)
    }
 
    recipients @requestor.email
    content_type "text/html" 
    from "College Swap <whowish@gmail.com>" 
    subject "Sorry, your swap was not accepted."
    sent_on Time.now 
    #body {} 
  end
  
  def test
    recipients "tanin47@yahoo.com"
    content_type "text/html" 
    from "College Swap <whowish@gmail.com>" 
    subject "Please add stuff "+word_for(:test_name)+" can trade"
    sent_on Time.now 
    #body {} 
  end
  
  def remind_no_item(requestor,responder,message,item_title) 
    @responder = responder
    @requestor = requestor
    @message = message
    @item_title = item_title
    if @requestor.gender == "female"
      @pronoun = "she"
      @possessive_pronoun = "her"
    else
      @pronoun = "he"
      @possessive_pronoun = "his"
    end
    
   
    @url_add_junk = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/myswappage?user_id=" + @responder.facebook_id
 
    recipients @responder.email
    content_type "text/html" 
    from "College Swap <whowish@gmail.com>" 
    subject "Please add stuff you can trade"
    sent_on Time.now 
    #body {} 
  end
  

end
