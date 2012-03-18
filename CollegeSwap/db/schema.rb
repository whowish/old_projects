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

ActiveRecord::Schema.define(:version => 20110801054626) do

  create_table "categories", :force => true do |t|
    t.string "name",                 :null => false
    t.string "parent_id",            :null => false
    t.string "original_image_path",  :null => false
    t.string "thumbnail_image_path", :null => false
  end

  create_table "colleges", :force => true do |t|
    t.string  "name",                                  :null => false
    t.integer "college_id",    :default => 0,          :null => false
    t.string  "status",        :default => "APPROVED", :null => false
    t.string  "country_code",  :default => "US"
    t.string  "place_name"
    t.text    "place_address"
  end

  create_table "comment_pendings", :force => true do |t|
    t.string "status"
    t.text   "data"
    t.string "unique_key"
  end

  create_table "comments", :force => true do |t|
    t.integer  "item_id"
    t.integer  "facebook_id",  :limit => 8, :null => false
    t.datetime "created_date"
    t.text     "comment"
  end

  create_table "countries", :force => true do |t|
    t.string "name", :null => false
    t.string "code", :null => false
  end

  create_table "currencies", :force => true do |t|
    t.string "country_code"
    t.string "name"
    t.string "format"
    t.string "sign"
    t.string "separator"
    t.string "delimiter"
    t.string "paypal_currency_code"
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
    t.string   "name",         :null => false
    t.string   "gender",       :null => false
    t.datetime "updated_date", :null => false
    t.string   "facebook_id",  :null => false
    t.string   "college",      :null => false
    t.string   "email"
  end

  add_index "facebook_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "facebook_friend_caches", :force => true do |t|
    t.string   "facebook_id",        :null => false
    t.text     "friends",            :null => false
    t.text     "friends_of_friends", :null => false
    t.datetime "updated_date",       :null => false
  end

  add_index "facebook_friend_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "flag_admin_records", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.string   "action",       :null => false
    t.datetime "created_date", :null => false
    t.string   "facebook_id",  :null => false
  end

  create_table "flags", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.string   "facebook_id",  :null => false
    t.datetime "created_date", :null => false
    t.string   "reason",       :null => false
  end

  create_table "item_images", :force => true do |t|
    t.string  "original_image_path", :null => false
    t.integer "ordered_number",      :null => false
    t.integer "item_id"
  end

  create_table "items", :force => true do |t|
    t.string   "title",                                    :null => false
    t.string   "item_type",                                :null => false
    t.float    "value"
    t.text     "description"
    t.string   "facebook_id",                              :null => false
    t.integer  "category_id",                              :null => false
    t.string   "status",             :default => "ACTIVE", :null => false
    t.datetime "created_date",                             :null => false
    t.datetime "expiration_date"
    t.integer  "is_money",           :default => 0,        :null => false
    t.integer  "flags",              :default => 0,        :null => false
    t.string   "owner_name",         :default => "",       :null => false
    t.string   "owner_university",   :default => "",       :null => false
    t.string   "default_image_path", :default => "",       :null => false
    t.string   "privacy"
    t.string   "country_code",       :default => "US"
  end

  create_table "members", :force => true do |t|
    t.string  "facebook_id",                 :null => false
    t.integer "college_id",                  :null => false
    t.integer "is_aesir",     :default => 0, :null => false
    t.text    "profile_text"
  end

  add_index "members", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "notifications", :force => true do |t|
    t.string   "notified_facebook_id"
    t.string   "facebook_id"
    t.integer  "item_id"
    t.datetime "created_date"
    t.boolean  "is_read"
  end

  add_index "notifications", ["notified_facebook_id"], :name => "index_notifications_on_notified_facebook_id"

  create_table "requests", :force => true do |t|
    t.integer  "requestor_item_id",                            :null => false
    t.integer  "responder_item_id",                            :null => false
    t.string   "requestor_facebook_id",                        :null => false
    t.string   "responder_facebook_id",                        :null => false
    t.text     "message"
    t.text     "response_message"
    t.string   "status",                :default => "PENDING", :null => false
    t.datetime "created_date",                                 :null => false
    t.datetime "response_time",                                :null => false
    t.integer  "is_read",               :default => 0,         :null => false
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
    t.string   "facebook_id",                            :null => false
    t.text     "params",                                 :null => false
    t.string   "ip_address",                             :null => false
    t.string   "controller_name",                        :null => false
    t.string   "action_name",                            :null => false
    t.string   "result",                                 :null => false
    t.datetime "accessed_date",                          :null => false
    t.string   "browser",                :default => ""
    t.text     "decoded_signed_request"
    t.text     "referer"
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
