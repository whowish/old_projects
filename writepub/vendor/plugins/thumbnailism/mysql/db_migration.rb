## define schema for files

begin 

  ActiveRecord::Schema.define do
    create_table "temporary_files", :force => false do |t|
      t.string   "name",         :null => false
      t.datetime "created_date", :null => false
    end
  end

rescue Exception=>e
  puts "Create whowish_words failed: #{e}"
end