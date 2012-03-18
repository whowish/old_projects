# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110706045954) do

  create_table "abouts", :force => true do |t|
    t.text "description", :limit => 16777215
  end

  create_table "activities", :force => true do |t|
    t.integer  "country_id",                       :null => false
    t.string   "topic",                            :null => false
    t.text     "description",  :limit => 16777215
    t.datetime "created_date"
  end

  create_table "activity_images", :force => true do |t|
    t.integer "activity_id"
    t.string  "original_image_path"
    t.integer "ordered_number"
  end

  create_table "conference_images", :force => true do |t|
    t.integer "conference_id"
    t.string  "original_image_path"
    t.integer "ordered_number"
  end

  create_table "conferences", :force => true do |t|
    t.integer  "country_id",                       :null => false
    t.string   "topic",                            :null => false
    t.text     "description",  :limit => 16777215
    t.datetime "created_date"
  end

  create_table "contacts", :force => true do |t|
    t.text "description", :limit => 16777215
  end

  create_table "countries", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "error_logs", :force => true do |t|
    t.datetime "time",        :null => false
    t.string   "ip_address"
    t.string   "identifier",  :null => false
    t.text     "description", :null => false
  end

  create_table "facebook_caches", :force => true do |t|
    t.string   "name",                      :null => false
    t.string   "gender"
    t.datetime "updated_date",              :null => false
    t.integer  "facebook_id",  :limit => 8
    t.string   "college"
    t.string   "email"
  end

  add_index "facebook_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "facebook_friend_caches", :force => true do |t|
    t.integer  "facebook_id",        :limit => 8
    t.text     "friends",                         :null => false
    t.text     "friends_of_friends",              :null => false
    t.datetime "updated_date",                    :null => false
  end

  add_index "facebook_friend_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "facebook_logs", :force => true do |t|
    t.text     "path"
    t.text     "sent",         :limit => 16777215
    t.text     "received",     :limit => 16777215
    t.datetime "created_date",                     :null => false
  end

  create_table "locks", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "member_confirmations", :force => true do |t|
    t.string  "unique_key", :null => false
    t.integer "member_id",  :null => false
  end

  create_table "member_forget_passwords", :force => true do |t|
    t.string   "unique_key",   :null => false
    t.integer  "member_id",    :null => false
    t.datetime "created_date", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "email",                                       :null => false
    t.string   "password"
    t.string   "name",                                        :null => false
    t.string   "status",                                      :null => false
    t.integer  "is_admin",                                    :null => false
    t.datetime "created_date",                                :null => false
    t.string   "profile_picture_path"
    t.string   "member_type",          :default => "GENERAL"
  end

  create_table "partners", :force => true do |t|
    t.string  "country",                                 :null => false
    t.text    "description",         :limit => 16777215
    t.string  "original_image_path"
    t.string  "url"
    t.string  "name"
    t.integer "ordered_number"
  end

  create_table "research_images", :force => true do |t|
    t.integer "research_id"
    t.string  "original_image_path"
    t.integer "ordered_number"
  end

  create_table "researches", :force => true do |t|
    t.integer  "country_id",                       :null => false
    t.string   "topic",                            :null => false
    t.text     "description",  :limit => 16777215
    t.datetime "created_date"
  end

  create_table "temporary_images", :force => true do |t|
    t.string   "name",         :null => false
    t.datetime "created_date", :null => false
  end

  create_table "traces", :force => true do |t|
    t.string   "facebook_id",     :null => false
    t.text     "params",          :null => false
    t.string   "ip_address",      :null => false
    t.string   "controller_name", :null => false
    t.string   "action_name",     :null => false
    t.string   "result",          :null => false
    t.string   "browser"
    t.text     "referer"
    t.datetime "accessed_date",   :null => false
  end

  create_table "whowish_word_emails", :force => true do |t|
    t.string "word_id", :null => false
    t.text   "content", :null => false
  end

  create_table "whowish_word_facebooks", :force => true do |t|
    t.string "publish_id",  :null => false
    t.string "message",     :null => false
    t.string "name",        :null => false
    t.string "caption",     :null => false
    t.text   "description", :null => false
  end

  create_table "whowish_words", :force => true do |t|
    t.string "word_id", :null => false
    t.text   "content", :null => false
  end

end
