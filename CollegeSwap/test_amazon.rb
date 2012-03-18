require 'test/unit'
require 'app/helpers/amazon_helper'
require 'vendor/plugins/rest-client/lib/restclient'

class TestAmazon < Test::Unit::TestCase
  include AmazonHelper
  
  def test_generate_sig
    find_item_amazon_by_keyword("harry potter",2)
  end
  
  
end