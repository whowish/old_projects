class AddRefererToTrace < ActiveRecord::Migration
  def self.up
    add_column :traces, :referer, :text
  end

  def self.down
  end
end
