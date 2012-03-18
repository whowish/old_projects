module WritepubEditor
  module Preprocessing
    
    class Iframe < Base
      
      def self.process(html)
        
        html.gsub(/<(iframe)([^>]*)>/i) { |iframe|
        
          tag = $1
          attrs = $2
          
          attrs = "#{attrs}".gsub(/ ([a-zA-Z]+)=[']?([^'"> ]+)[']?/) { |attr|
             " #{$1}=\"#{$2}\""
          }
          
          attrs = "#{attrs}".gsub(/ [a-zA-Z]+/) { |attr|
       
            if "#{$'}".match(/\A=/) == nil
              "#{attr}=\"\""
            else
              attr
            end
          }
          
          "<#{tag}#{attrs}>"
        }
        
      end
      
    end
    
  end
end