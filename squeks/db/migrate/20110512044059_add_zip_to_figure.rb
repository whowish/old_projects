class AddZipToFigure < ActiveRecord::Migration

   
  def self.up
      
    add_column :figures,:zip_file_path, :string, :default=>nil

  end

  def self.down
  end
end
