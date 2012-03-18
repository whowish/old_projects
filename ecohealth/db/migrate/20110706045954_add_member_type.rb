class AddMemberType < ActiveRecord::Migration
  def self.up
    add_column :members, :profile_picture_path, :string
    add_column :members, :member_type, :string,:default => Member::TYPE_GENERAL
  end

  def self.down
    remove_column :members, :profile_picture_path
    remove_column :members, :member_type
  end
end
