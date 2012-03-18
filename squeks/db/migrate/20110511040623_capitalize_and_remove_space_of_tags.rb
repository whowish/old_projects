class CapitalizeAndRemoveSpaceOfTags < ActiveRecord::Migration
  def self.up
    begin
    Tag.all.each { |tag|
      tag.name = tag.name.split(' ').join(' ').strip.capitalize
      tag.save
    }
    
    Figure.all.each { |figure|
      figure.tags = "" if figure.tags == nil
      tags = figure.tags.split("</t><t>")
      
      next if tags.length == 0
      
      if tags.length == 1 and tags[0].strip == ""
        figure.tags = ""
      else
        # chop front-back
        if tags.length > 0
          tags[0] = tags.first[3..-1]
          tags[-1] = tags.last[0..-5]
        end
        
        tags = tags.map { |i| "<t>#{i.split(' ').join(' ').strip.capitalize}</t>" }
        figure.tags = tags.join('')
       
      end
      
      figure.save
    }
  rescue
    end
  end

  def self.down
  end
end
