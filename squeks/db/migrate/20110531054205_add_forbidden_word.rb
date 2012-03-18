class AddForbiddenWord < ActiveRecord::Migration
  def self.up
    create_table :forbidden_words do |t|
      t.string :word
    end
  end

  def self.down
    drop_table :forbidden_words
  end
end
