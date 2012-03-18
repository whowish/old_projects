class AddBrowserToTrace < ActiveRecord::Migration
  def self.up
    add_column :traces, :browser, :string
    add_column :traces, :decoded_signed_request, :text
  end

  def self.down
  end
end
