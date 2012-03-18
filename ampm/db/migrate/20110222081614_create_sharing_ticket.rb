class CreateSharingTicket < ActiveRecord::Migration
  def self.up
    create_table :share_tickets do |t|
      t.string :unique_key
      t.string :permission
      t.datetime :created_date
      t.datetime :finished_date, :default=>nil
      t.string :status
      t.string :ref
      t.text :error_message
    end
  end

  def self.down
    drop_table :share_tickets
  end
end