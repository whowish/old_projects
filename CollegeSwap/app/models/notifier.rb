class Notifier < ActionMailer::Base
  #default :from => "notifications@example.com"    
  
  def request_swap(requestor,responder)       
    recipients responder.email
    from "College Swap <notifications@example.com>" 
    subject requestor.name + " has sent a request to swap"
    sent_on Time.now 
    #body {} 
  end

end
