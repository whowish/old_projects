require 'nokogiri'

module Nokogiri
  module XML
    
    class Node
  
      def remove_all_attributes(*except)
        
        except = except.map { |attr| attr.to_s }
        
        self.attribute_nodes.each { |n|
          next if except.include?(n.node_name)
          self.remove_attribute(n.node_name)
        }
      end
      
      def extract_inside_out
        
        next_sibling_instance = self.next_sibling
        parent_instance = self.parent
        
        move_node_proc = (next_sibling_instance == nil) ? \
                            Proc.new { |c| parent_instance.add_child(c) } : \
                            Proc.new { |c| next_sibling_instance.add_previous_sibling(c) }
                                                  
        
        self.children.each { |c|
          move_node_proc.call(c)
        }
        
      end
    
    end
  
  
  end
end