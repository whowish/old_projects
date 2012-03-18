class AddWikyContentToKratoo < Mongoid::Migration
  def self.up
    Kratoo.all.each { |kratoo|
    
      content = kratoo[:content]
      next if !content.kind_of?(String)
      
      kratoo[:content] = WikyMongo.new
      kratoo[:content].set_raw_content(content)
      kratoo.save
    }
  end

  def self.down
  end
end