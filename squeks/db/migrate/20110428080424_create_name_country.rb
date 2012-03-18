class CreateNameCountry < ActiveRecord::Migration
  def self.up
    create_table :languages, :force => true do |t|
      t.string   :name, :null => false
      t.string   :code, :null => false
    end
    create_table :countries, :force => true do |t|
      t.string   :name, :null => false
      t.string   :code, :null => false
    end
    
    Language.create({:name=>"English",:code=>"US"})
    Language.create({:name=>"Thai",:code=>"TH"})
    Language.create({:name=>"Japanese",:code=>"JP"})
    Language.create({:name=>"Korean",:code=>"KR"})
    Language.create({:name=>"Mandarin Chinese",:code=>"CN"})
    
    Country.create({:name=>"USA",:code=>"US"})
    Country.create({:name=>"Thailand",:code=>"TH"})
    Country.create({:name=>"Japan",:code=>"JP"})
    Country.create({:name=>"Korea",:code=>"KR"})
    Country.create({:name=>"China",:code=>"CN"})
    
    rename_column :figures, :title,:title_us
    add_column :figures, :title_th, :string
    add_column :figures, :title_jp, :string
    add_column :figures, :title_kr, :string
    add_column :figures, :title_cn, :string
    add_column :figures, :tags, :text
    
  end

  def self.down
     drop_table :countries
     drop_table :languages
  end
end
