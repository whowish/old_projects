set :application, "friendmage"
set :domain,      "72.26.225.10"
set :repository,  "git@github.com:tanin47/friendmage.git"

set :use_sudo,    false
set :deploy_to,   "/#{application}"
set :scm,         "git"
set :git_enable_submodules,1

set :user, "deploy"

set :branch, "master"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end
 
 namespace :image_generator do
  task :stop_package do
    begin
      run "cd #{current_path}/FriendPosterGenerator; chmod 755 friendmage; ./friendmage stop"
    rescue
    end
    #run 'for pid in `ps -Ao pid,command | grep image_generator | grep -v grep | sed "s/^[ ]*//" | cut --delimiter=" " -f1` ; do kill -9 $pid ; done'

  end
   
  task :run_package do
    run "cd #{current_path}/FriendPosterGenerator; chmod 755 friendmage; ./friendmage start >/dev/null 2>&1"
    #run "cd #{current_path}/FriendPosterGenerator; pwd; nohup java -Xms512m -Xmx1024m -jar #{current_path}/FriendPosterGenerator/store/image_generator.jar &", :pty => true 
  end
 end
 
set :shared_assets, ['public/uploads','log']

namespace :assets  do
  namespace :symlinks do
#    desc "Setup application symlinks for shared assets"
#    task :setup, :roles => [:app, :web] do
#      shared_assets.each { |link| 
#        run "mkdir -p #{shared_path}/#{link}" 
#        run "chmod 777 #{shared_path}/#{link}"
#        run "chmod 777 #{release_path}/#{link}"
#      }
#    end

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_assets.each { |link|
        begin 
          run "mkdir -p #{shared_path}/#{link}; chmod 777 #{release_path}/#{link}; rm -fr #{release_path}/#{link}" 

        rescue
        end

        #use shared instead
        run "chmod 777 #{shared_path}/#{link}; ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" 

      }
    end
  end
end

# add this to config/deploy.rb
namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => [:app, :web] do
    run "cd #{current_path}; chmod 755 script/delayed_job; script/delayed_job start production"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => [:app, :web] do
    run "cd #{current_path}; chmod 755 script/delayed_job; script/delayed_job stop production"
  end

end


before "deploy" do 
  image_generator.stop_package
  delayed_job.stop
end

before "deploy:symlink" do
  assets.symlinks.update
end

after "deploy:symlink" do
  image_generator.run_package
  delayed_job.start
end


