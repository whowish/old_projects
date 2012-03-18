class CreateCurrency < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :country_code
      t.string :name
      t.string :format
      t.string :sign
      t.string :separator
      t.string :delimiter
      t.string :paypal_currency_code
    end
  end

  def self.down
    drop_table :currencies
  end
end
