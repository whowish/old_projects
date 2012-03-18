if defined? ActionController

  ActionController::Base.class_eval do
    alias_method :process_without_dynonamics,:process_action
    
    def process_action(method_name, *args)
      dynonamics_start_second = Time.now.to_f 
      
      v = process_without_dynonamics(method_name, *args)
      
      dynonamics_end_second = Time.now.to_f
      
      if rand(10) == 5
        data = {:http_x_request_start=>(heroku_info['HTTP_X_REQUEST_START'].to_f/1000.to_f),
         :rails_start=>dynonamics_start_second,
         :rails_end=>dynonamics_end_second,
         :http_x_heroku_queue_wait_time=>(heroku_info['HTTP_X_HEROKU_QUEUE_WAIT_TIME'].to_f/1000.to_f),
         :http_x_heroku_dyno_in_use=>heroku_info['HTTP_X_HEROKU_DYNOS_IN_USE'],
         :http_x_heroku_queue_depth=>heroku_info['HTTP_X_HEROKU_QUEUE_DEPTH']}
        
        DynonamicsClient.submit_dyno_time(data)
      end
      
      return v
    end
    
  end
end