require 'net/http'
require 'net/https'
require 'uri'

Net::HTTP.version_1_2


def fetch(uri_str, limit = 4)

  print uri_str+"\n"

  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)

  http = Net::HTTP.new(url.host,url.port)

  response = http.get(url.path+"?"+url.query.to_s)
  
  print response.inspect

  if  response.is_a? Net::HTTPRedirection
    response = fetch(response['location'], limit - 1)
  end

  return response
end

response = fetch('http://profile.ak.fbcdn.net/static-ak/rsrc.php/v1/yp/r/yDnr5YfbJCH.gif')

require File.expand_path(File.dirname(__FILE__) + "/vendor/plugins/whowish_foundation/lib/image_temp_file")
require File.expand_path(File.dirname(__FILE__) + "/vendor/plugins/whowish_foundation/lib/mini_magick")
#require File.expand_path(File.dirname(__FILE__) + "/vendor/plugins/whowish_foundation/lib/mini_magick_init")

image = MiniMagick::Image.from_blob(response.body)


image.resize "10%"
image.resize "1000%"


image.write File.dirname(__FILE__) + "/test.jpg"