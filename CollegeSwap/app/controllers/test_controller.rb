class TestController < ActionController::Base
  include AmazonHelper
  
  def index
    
    require 'rexml/document'
    products = find_item_amazon_by_keyword("laptop",5)

    render :text=>products.map {|i|i.title}.join("<br/>")
  end
  

end
