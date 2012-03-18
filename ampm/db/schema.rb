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

ActiveRecord::Schema.define(:version => 20110304081151) do

  create_table "categories", :force => true do |t|
    t.string "name",                 :null => false
    t.string "parent_id",            :null => false
    t.string "original_image_path",  :null => false
    t.string "thumbnail_image_path", :null => false
    t.string "class_name",           :null => false
  end

  create_table "comment_likes", :force => true do |t|
    t.integer  "comment_id"
    t.string   "facebook_id"
    t.datetime "created_date"
  end

  create_table "comments", :force => true do |t|
    t.integer  "event_id"
    t.string   "facebook_id"
    t.datetime "created_date"
    t.text     "comment"
    t.integer  "like"
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

  create_table "event_available_dates", :force => true do |t|
    t.integer  "event_id",       :null => false
    t.string   "facebook_id",    :null => false
    t.datetime "available_date", :null => false
  end

  create_table "event_friends", :force => true do |t|
    t.integer "event_id",                           :null => false
    t.string  "facebook_id",                        :null => false
    t.string  "status",      :default => "PENDING", :null => false
    t.string  "name",        :default => ""
    t.integer "is_approved", :default => 1
    t.string  "invited_by"
  end

  create_table "event_images", :force => true do |t|
    t.integer "event_id",            :null => false
    t.string  "original_image_path", :null => false
    t.integer "ordered_number",      :null => false
  end

  create_table "event_settled_dates", :force => true do |t|
    t.integer  "event_id",     :null => false
    t.datetime "settled_date", :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "title",                                    :null => false
    t.string   "location",           :default => "",       :null => false
    t.string   "location_url",       :default => "",       :null => false
    t.text     "description"
    t.string   "facebook_id",                              :null => false
    t.string   "status",             :default => "ACTIVE", :null => false
    t.datetime "created_date",                             :null => false
    t.datetime "settled_date",                             :null => false
    t.string   "default_image_path", :default => "",       :null => false
    t.integer  "category_id",                              :null => false
    t.string   "mode",               :default => "TIME"
  end

  create_table "facebook_caches", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "gender",       :null => false
    t.datetime "updated_date", :null => false
    t.string   "facebook_id",  :null => false
    t.string   "college",      :null => false
    t.string   "email"
  end

  add_index "facebook_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "facebook_friend_caches", :force => true do |t|
    t.string   "facebook_id",  :null => false
    t.text     "friends",      :null => false
    t.datetime "updated_date", :null => false
  end

  add_index "facebook_friend_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "facebook_friend_records", :force => true do |t|
    t.string "facebook_id", :null => false
    t.string "friend_id",   :null => false
    t.string "name",        :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "share_tickets", :force => true do |t|
    t.string   "unique_key"
    t.string   "permission"
    t.datetime "created_date"
    t.datetime "finished_date"
    t.string   "status"
    t.string   "ref"
    t.text     "error_message"
  end

  create_table "temporary_images", :force => true do |t|
    t.string   "name",         :null => false
    t.datetime "created_date", :null => false
  end

  create_table "traces", :force => true do |t|
    t.string   "facebook_id",            :null => false
    t.text     "params",                 :null => false
    t.string   "ip_address",             :null => false
    t.string   "controller_name",        :null => false
    t.string   "action_name",            :null => false
    t.string   "result",                 :null => false
    t.datetime "accessed_date",          :null => false
    t.string   "browser"
    t.text     "decoded_signed_request"
    t.text     "referer"
  end

  create_table "whowish_words", :force => true do |t|
    t.string "page_name", :null => false
    t.string "page_id",   :null => false
    t.string "word_id",   :null => false
    t.text   "content",   :null => false
    t.string "locale",    :null => false
  end

end
