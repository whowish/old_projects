class AddReasonToFigure < ActiveRecord::Migration
  def self.up
    add_column :figures, :reason, :string
  end

  def self.down
    drop_table :figures
  end
end