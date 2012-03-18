require 'resque/tasks'
require 'resque_scheduler/tasks'

# Start a worker with proper env vars and output redirection
def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
                          :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
  env_vars = {"QUEUE" => queue.to_s,
              "RAILS_ENV" => "production"}
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "nohup rake environment resque:work >/dev/null 2>&1 &", ops)
    Process.detach(pid)
  }
end

namespace :resque do
  
  task "resque:setup" => :environment

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end
  
  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = []
    Resque.workers.each do |worker|
      pids.push("#{worker.pid}")
    end
    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end
  
  desc "Start workers"
  task :start_workers => :environment do
    run_worker("member_action", 1)
    run_worker("notification", 1)
    run_worker("normal", 1)
  end
end
