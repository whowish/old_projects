ENV["RAILS_ENV"] ||= 'test'
  
require File.expand_path("../../../config/environment", __FILE__)
  
$app = Rack::Builder.new {
  map "/" do
    if Rails.version.to_f >= 3.0
      run Rails.application  
    else # Rails 2
      use Rails::Rack::Static
      run ActionController::Dispatcher.new
    end
  end
}.to_app

def timeout(seconds = 1, driver = nil, error_message = nil, &block)
  start_time = Time.now

  result = nil

  until result
    return result if result = yield

    delay = seconds - (Time.now - start_time)
    if delay <= 0
      raise TimeoutError, error_message || "timed out"
    end

    driver && driver.wait_until(delay)

    sleep(0.05)
  end
end

class Identify
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] == "/__identify__"
        [200, {}, [@app.object_id.to_s]]
      else
        @app.call(env)
      end
    end
  end

require 'rack'

Thread.new do
  Rack::Handler::WEBrick.run(Identify.new($app), :Port => 57124)
end

require 'uri'
require 'net/http'
def responsive?
  res = Net::HTTP.start("localhost", 57124) { |http| http.get('/__identify__') }

  if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    return res.body == $app.object_id.to_s
  end
rescue Errno::ECONNREFUSED, Errno::EBADF
  return false
end

timeout(60) do
  if responsive? 
    true 
  else 
    sleep(0.5)
    false 
  end
end

print "HELLO"