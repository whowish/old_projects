set :application, "CollegeSwap"
set :domain,      "72.26.225.10"
set :repository,  "git@github.com:tanin47/CollegeSwap.git"

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
 
set :shared_assets, ['public/uploads']

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
          run "mkdir -p #{shared_path}/#{link}" 
        rescue
      end
      
        run "chmod 777 #{shared_path}/#{link} && chmod 777 #{release_path}/#{link}"
        run "rm -fr #{release_path}/#{link} && ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" 
      }
    end
  end
end

before "deploy:symlink" do
  assets.symlinks.update
end
