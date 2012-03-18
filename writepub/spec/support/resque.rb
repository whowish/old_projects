# encoding: utf-8
require 'resque_spec/scheduler'

Resque.redis = Redis.new(:host => "localhost", :port => 9736)

# Hook to overwrite resque-scheduler
Resque.module_eval do 
 
  def self.enqueue_at(timestamp,klass,*args)
    enqueue(klass,*args)
  end
  
  def self.enqueue_in(timestamp,klass,*args)
    enqueue(klass,*args)
  end
end