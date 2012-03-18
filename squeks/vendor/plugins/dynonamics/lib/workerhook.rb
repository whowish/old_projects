#if defined? Delayed
#  
#  if defined? Delayed::Job
#
#    Delayed::Job.class_eval do
#        alias_method :workoff_without_dynonamics,:work_off
#        
#        def self.work_off(num = 100)
#          
#          dynonamics_start_second = Time.now.to_r 
#          
#          v = workoff_without_dynonamics(num)
#          
#          DynonamicsClient.submit_worker_time(Time.now.to_r - dynonamics_start_second)
#          
#          return v
#        end
#    end
#  end
#end