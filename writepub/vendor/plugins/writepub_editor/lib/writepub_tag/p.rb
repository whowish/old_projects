module WritepubEditor
  module WritepubTag
    
    class P < Base
      
      def is_match
        @node.name.downcase == "p"
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        next_sibling = @node.next_sibling
        parent = @node.parent
                                 
        @node.extract_inside_out
        
        move_node_proc = (next_sibling == nil) ? \
                            Proc.new { |c| parent.add_child(c) } : \
                            Proc.new { |c| next_sibling.add_previous_sibling(c) }
                            
        2.times { 
          br = Nokogiri::XML::Node.new("br", @node.document)
          move_node_proc.call(br) 
        }
        
        @node.remove
        
      end
    end
    
  end
end