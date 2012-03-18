class CreateAdmin < ActiveRecord::Migration
  def self.up
    create_table :abouts do |t|
      t.column "description", 'mediumtext'
    end
    create_table :contacts do |t|
      t.column "description", 'mediumtext'
    end
    create_table :partners do |t|
      t.string "country", :null => false
      t.column "description", 'mediumtext'
    end
    create_table :countries do |t|
      t.string "name", :null => false
    end
    
    Country.create(:name=>"Bangladesh")
    Country.create(:name=>"Bhutan")
    Country.create(:name=>"Cambodia")
    Country.create(:name=>"South China")
    Country.create(:name=>"India")
    Country.create(:name=>"Indonesia")
    Country.create(:name=>"Laos")
    Country.create(:name=>"Maldives")
    Country.create(:name=>"Malaysia")
    Country.create(:name=>"Myanmar")
    Country.create(:name=>"Nepal")
    Country.create(:name=>"Pakistan")
    Country.create(:name=>"Singapore")
    Country.create(:name=>"Sri Lanka")
    Country.create(:name=>"Philippines")
    Country.create(:name=>"Thailand")
    Country.create(:name=>"Vietnam")
    
    create_table :activities do |t|
      t.integer "country_id", :null => false
      t.string "topic", :null => false
      t.column "description", 'mediumtext'
      t.datetime "created_date"
    end
    create_table :researches do |t|
      t.integer "country_id", :null => false
      t.string "topic", :null => false
      t.column "description", 'mediumtext'
      t.datetime "created_date"
    end
    create_table :conferences do |t|
      t.integer "country_id", :null => false
      t.string "topic", :null => false
      t.column "description", 'mediumtext'
      t.datetime "created_date"
    end
    create_table :activity_images do |t|
      t.integer  :activity_id
      t.string   :original_image_path
      t.integer  :ordered_number
    end
    create_table :research_images do |t|
      t.integer  :research_id
      t.string   :original_image_path
      t.integer  :ordered_number
    end
    create_table :conference_images do |t|
      t.integer  :conference_id
      t.string   :original_image_path
      t.integer  :ordered_number
    end
  end

  def self.down
    drop_table :news_images
    drop_table :conferences
    drop_table :researches
    drop_table :activities
    drop_table :countries
    drop_table :partners
    drop_table :contacts
    drop_table :abouts
  end
end
