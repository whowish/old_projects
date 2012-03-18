# encoding: utf-8
require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  
  
  
  require File.expand_path("../../config/environment", __FILE__)
  
  require 'rspec/rails'
  
  require 'watir-webdriver-rails'
  
  WatirWebdriverRails.host = "localhost"
  WatirWebdriverRails.port = 57124
#  require 'capybara/rspec'
#  require 'capybara/rails'
#  require 'capybara/firebug'
#  
#  Capybara.default_driver = :selenium_with_firebug
# 
#  Capybara.server_port = 57124
#  Capybara.app_host = "http://localhost:#{Capybara.server_port}"
  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  require 'win32/process'
  
  
  RSpec.configure do |config|
    
    config.include Browser
    config.include MongoidHelper
    config.include ResqueHelper
    config.include DebuggerHelper
    config.include JsonRspecHelper
    
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec
  
    # Solr stub
    require 'sunspot/rails/spec_helper'
    config.before(:each) do
      ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
    end
  
    config.after(:each) do
      ::Sunspot.session = ::Sunspot.session.original_session
    end
  
    # Database cleaner setting
    require 'database_cleaner'
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = "mongoid"
    end
    
    config.before(:each) do
      DatabaseCleaner.clean
      $redis.flushall
      Mongoid.database.command({:getlasterror => 1,:fsync=>true})
    end
    
    # Mongoid setup
    config.include Mongoid::Matchers
    
    # ResqueSpec setup
    config.before(:each) do
      ResqueSpec.reset!
#      Capybara.current_driver = :selenium_with_firebug
    end
 
    # index all models
    config.before(:suite) do
      
      DatabaseCleaner.clean
      
      all_files = Dir.glob(Rails.root.join('app', 'models', '*.rb'))
      all_models = all_files.map { |path| File.basename(path, '.rb').camelize.constantize }
      mongoid_models = all_models.select { |m| m.respond_to?(:create_indexes) }
      
      mongoid_models.each do |model|
  
        begin
          model.collection.drop_indexes
        rescue Exception
        end
        
        begin
          model.create_indexes
        rescue Exception=>e
          puts "Error while indexing #{model.name}"
          raise e
        end
      end
    end
    
    ActiveSupport::Dependencies.clear 
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f } 
  
end


