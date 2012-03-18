require 'nokogiri'
Dir[File.expand_path("../nokogiri/**/*.rb", __FILE__)].each {|f| require f}
require File.expand_path("../writepub_tag", __FILE__)

module WritepubEditor
  include WritepubTag
  
  class Base
    
    @@preprocessing_rules = [Preprocessing::Br,
                            Preprocessing::Iframe,
                            Preprocessing::Img
                            ]
  
    @@tranformations = [ WritepubTag::A,
                        WritepubTag::B,
                        WritepubTag::Br,
                        WritepubTag::Em,
                        WritepubTag::I,
                        WritepubTag::Img,
                        WritepubTag::P,
                        WritepubTag::Root,
                        WritepubTag::SpanBold,
                        WritepubTag::SpanItalic,
                        WritepubTag::Strong,
                        WritepubTag::Text,
                        WritepubTag::Youtube
                        ]
                        
    def initialize(html)
      html = "<root>#{html}</root>"
      
      @@preprocessing_rules.each { |tag|
        html = tag.process(html)
      }
      
      @doc = Nokogiri::XML( html ) { |config| 
        config.noblanks
      }
      
      traverse(@doc.root)

    end
    
    def text
      @doc.root.content.strip
    end
    
    def get_images
      
      srcs = []
      
      @doc.xpath("//img").each { |img|
        srcs.push(img.get_attribute("src"))
      }
      
      return srcs
      
    end
    
    def to_s
      return @doc.root.to_xhtml(:indent=>0,:encoding=>"UTF-8").sub(/^<root>/,"").sub(/<\/root>$/,"").strip
    end
    
    private
    def traverse(node)
      
      node.children.each { |c|
        traverse(c)
      }
      
      transformed = false
      @@tranformations.each { |tag|  
        t = tag.new(node)
        
        next if !t.is_match
        t.transform
        
        transformed = true
      }
      
      if transformed == false
        node.extract_inside_out
        node.remove
      end
      
    end
    
  end
  
end