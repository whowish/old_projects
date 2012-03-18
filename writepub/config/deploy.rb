set :application, "writepub"
set :domain,      "72.26.225.10"
set :repository,  "git@github.com:tanin47/writepub.git"

set :use_sudo,    false
set :deploy_to,   "/#{application}"
set :scm,         "git"
set :git_enable_submodules, 0

set :user, "deploy"

set :branch, "deploy"

set :default_env, "production"
set :rails_env,     ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

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
 
set :shared_assets, ['public/uploads','solr/data','solr/lib','bundle']

namespace :assets  do
  namespace :symlinks do

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_assets.each { |link|
        begin 
          run "mkdir -p #{shared_path}/#{link} && chmod 777 #{release_path}/#{link}" 
        rescue
        end

        run "chmod 777 #{shared_path}/#{link} && ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" 

      }
    end
  end
end

# add this to config/deploy.rb
namespace :resque do
  desc "Start delayed_job process"
  task :start, :roles => [:app, :web] do
    run "cd #{current_path} && bundle exec rake resque:start_workers"
    run "cd #{current_path} && bundle exec rake resque:start_scheduler"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => [:app, :web] do
    run "cd #{current_path} && bundle exec rake resque:stop_workers"
    run "cd #{current_path} && bundle exec rake resque:stop_scheduler"
  end

end

namespace :sunspot do
  desc "Start sunspot process"
  task :start, :roles => [:app, :web] do
    run "cd #{current_path} && bundle exec sunspot-solr start -p 8390 -d solr/data/production -s solr --pid-dir=tmp/pids RAILS_ENV=#{rails_env}"
  end
  
  desc "Stop sunspot process"
  task :stop, :roles => [:app, :web] do
    begin
      run "cd #{current_path} && bundle exec sunspot-solr stop --pid-dir=tmp/pids RAILS_ENV=#{rails_env}"
    rescue
    end
  end

end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, 'vendor/bundle')
    run("mkdir -p #{shared_dir} && ln -nfs #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test --without development --path vendor/bundle "
  end
end


before "deploy" do 
  resque.stop
  sunspot.stop
end

after "deploy:symlink" do
  assets.symlinks.update
  bundler.bundle_new_release
end

after "deploy" do
  resque.start
  sunspot.start
end



