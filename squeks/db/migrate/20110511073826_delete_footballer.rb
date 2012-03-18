class DeleteFootballer < ActiveRecord::Migration
  def self.up
    footballer_tag = Tag.first(:conditions=>{:name=>"Footballer"})
    
    return if !footballer_tag
    
    FigureTag.all(:conditions=>{:tag_id=>footballer_tag.id}).each do |figure_tag|
      figure_id = figure_tag.figure_id
      figure_tag.destroy
      
      figure = Figure.first(:conditions=>{:id=>figure_id})
      figure.tags = figure.get_tags_column
      figure.save
    end
  end

  def self.down
  end
end
