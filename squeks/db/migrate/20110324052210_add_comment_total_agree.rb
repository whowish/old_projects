class AddCommentTotalAgree < ActiveRecord::Migration
  def self.up
    add_column :comments, :total_agree, :integer,:null => false, :default => 0
  end

  def self.down
    remove_column :comments, :total_agree
  end
end
