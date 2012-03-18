# Resque tasks
require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'resque'
require 'resque_scheduler'
require 'resque/scheduler'  
require 'daemon_spawn'

class ResqueSchedulerDaemon < DaemonSpawn::Base
  def start(args)
    Resque::Scheduler.verbose = true
    Resque::Scheduler.run
  end

  def stop
    Resque::Scheduler.shutdown
  end
end

namespace :resque do
  
  task :setup do
    
    yml = YAML.load_file "#{Rails.root.to_s}/config/resque.yml"
    config = yml[Rails.env.to_s.downcase]
    
    Resque.redis = Redis.new(:host => config['host'], :port => config['port'])

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    #Resque.schedule = YAML.load_file('your_resque_schedule.yml')

    # If your schedule already has +queue+ set for each job, you don't
    # need to require your jobs.  This can be an advantage since it's
    # less code that resque-scheduler needs to know about. But in a small
    # project, it's usually easier to just include you job classes here.
    # So, someting like this:
    #require 'jobs'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for 
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    #Resque::Scheduler.dynamic = true
  end
  
  task :start_scheduler do
    
   raise 'resque_scheduler.pid exists. Please erase it first and run again.' \
            if File.exist?(File.join(Rails.root,"tmp/pids/resque_scheduler.pid"))
    
    puts "Starting Resque Scheduler"
    
#    ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
#                          :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
#    env_vars = {"RAILS_ENV" => "production"}
#    
#    system(env_vars, "nohup rake resque:scheduler >/dev/null 2>&1 & && echo", ops)
    #File.open(File.join(Rails.root,"tmp/pids/resque_scheduler.pid"), 'w') { |f| f.write("#{Process.pid}") }
    
    ResqueSchedulerDaemon.spawn!({
      :log_file => File.join(Rails.root.to_s, "log", "resque_scheduler.log"),
      :pid_file => File.join(Rails.root.to_s, 'tmp', 'pids', 'resque_scheduler.pid'),
      :sync_log => true,
      :working_dir => Rails.root.to_s,
      :singleton => true
    },["start"])
    
  end
  
  task :stop_scheduler do
    
#      next if !File.exist?(File.join(Rails.root,"tmp/pids/resque_scheduler.pid"))
#      
#      pid = File.open(File.join(Rails.root,"tmp/pids/resque_scheduler.pid"), "r").read
#      
#      syscmd = "kill -s QUIT #{pid}"
#      puts "Running syscmd: #{syscmd}"
#      system(syscmd)
#      
#      File.delete(File.join(Rails.root,"tmp/pids/resque_scheduler.pid"))
    ResqueSchedulerDaemon.spawn!({
      :log_file => File.join(Rails.root.to_s, "log", "resque_scheduler.log"),
      :pid_file => File.join(Rails.root.to_s, 'tmp', 'pids', 'resque_scheduler.pid'),
      :sync_log => true,
      :working_dir => Rails.root.to_s,
      :singleton => true
    },["stop"])

  end
  
end