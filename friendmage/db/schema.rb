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

ActiveRecord::Schema.define(:version => 20110418104100) do

  create_table "apps", :force => true do |t|
    t.string "name",      :null => false
    t.string "desc"
    t.string "image_url"
    t.string "app_id"
  end

  create_table "banks", :force => true do |t|
    t.string "bank_name",      :null => false
    t.string "bank_branch",    :null => false
    t.string "account_number", :null => false
    t.string "account_name",   :null => false
    t.string "account_type",   :null => false
  end

  create_table "birthday_calendars", :force => true do |t|
    t.text     "birthday_information", :limit => 16777215, :null => false
    t.string   "friendmage_order_key",                     :null => false
    t.integer  "offset_x",                                 :null => false
    t.integer  "offset_y",                                 :null => false
    t.integer  "gap_x",                                    :null => false
    t.integer  "gap_y",                                    :null => false
    t.integer  "year",                                     :null => false
    t.string   "background_color",                         :null => false
    t.string   "mode",                                     :null => false
    t.datetime "created_date",                             :null => false
    t.integer  "width",                                    :null => false
    t.integer  "height",                                   :null => false
    t.string   "status"
  end

  create_table "cancel_orders", :force => true do |t|
    t.integer  "order_id",           :null => false
    t.string   "reason"
    t.string   "cus_account_number"
    t.datetime "created_date",       :null => false
    t.string   "old_status"
  end

  create_table "confirm_transfers", :force => true do |t|
    t.integer  "order_id",                              :null => false
    t.integer  "transfer_to_bank_id",                   :null => false
    t.string   "member_tel"
    t.string   "transfer_from_branch"
    t.datetime "transfer_date",                         :null => false
    t.float    "transfer_price",       :default => 0.0, :null => false
    t.datetime "created_date",                          :null => false
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

  create_table "facebook_friend_records", :force => true do |t|
    t.string "facebook_id", :null => false
    t.string "friend_id",   :null => false
    t.string "name",        :null => false
  end

  create_table "facebook_logs", :force => true do |t|
    t.text     "path"
    t.text     "sent",         :limit => 16777215
    t.text     "received",     :limit => 16777215
    t.datetime "created_date",                     :null => false
  end

  create_table "friend_posters", :force => true do |t|
    t.text     "image_urls",           :limit => 16777215, :null => false
    t.string   "friendmage_order_key",                     :null => false
    t.integer  "gap",                                      :null => false
    t.integer  "border",                                   :null => false
    t.string   "background_color",                         :null => false
    t.integer  "photo_per_row",                            :null => false
    t.datetime "created_date",                             :null => false
    t.integer  "width",                                    :null => false
    t.integer  "height",                                   :null => false
    t.string   "status"
  end

  create_table "locks", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "facebook_id",         :limit => 8,                    :null => false
    t.string   "name",                                                :null => false
    t.string   "gender",                                              :null => false
    t.datetime "updated_date",                                        :null => false
    t.string   "recipient_name"
    t.string   "address_identifier"
    t.string   "address_street"
    t.string   "address_subdistrict"
    t.string   "address_district"
    t.string   "address_province"
    t.string   "address_postal_code"
    t.boolean  "is_aesir",                         :default => false, :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer  "facebook_id",         :limit => 8,                  :null => false
    t.string   "key",                                               :null => false
    t.string   "app_id",                                            :null => false
    t.datetime "created_date",                                      :null => false
    t.string   "recipient_name"
    t.string   "address_identifier"
    t.string   "address_street"
    t.string   "address_subdistrict"
    t.string   "address_district"
    t.string   "address_province"
    t.string   "address_postal_code"
    t.float    "price",                            :default => 0.0, :null => false
    t.float    "shipping_price",                   :default => 0.0, :null => false
    t.string   "status"
    t.string   "payment_type"
    t.string   "preview_image_url"
    t.string   "print_image_url"
    t.string   "signature_image_url"
    t.datetime "paid_time"
    t.datetime "print_time"
    t.datetime "ship_time"
    t.string   "paypal_pay_key"
    t.boolean  "buy_digital_copy"
    t.boolean  "buy_print_copy"
  end

  create_table "payment_issues", :force => true do |t|
    t.integer "order_id", :null => false
    t.text    "issue"
  end

  create_table "paypal_ipns", :force => true do |t|
    t.datetime "created_date",                         :null => false
    t.string   "remote_host"
    t.integer  "order_id",                             :null => false
    t.string   "status",                               :null => false
    t.string   "payment_status"
    t.text     "paypal_status"
    t.string   "test_ipn"
    t.string   "transaction_type"
    t.string   "sender_email"
    t.string   "pay_key"
    t.text     "raw",              :limit => 16777215, :null => false
    t.text     "error",            :limit => 16777215
  end

  create_table "price_lists", :force => true do |t|
    t.string "paper_type",                  :null => false
    t.string "print_type",                  :null => false
    t.string "width",                       :null => false
    t.string "height",                      :null => false
    t.float  "price",      :default => 0.0, :null => false
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
    t.datetime "accessed_date",   :null => false
    t.string   "browser"
    t.text     "referer"
  end

  create_table "whowish_word_emails", :force => true do |t|
    t.string "page_id", :null => false
    t.string "word_id", :null => false
    t.text   "content", :null => false
    t.string "locale",  :null => false
  end

  create_table "whowish_word_facebooks", :force => true do |t|
    t.string "publish_id",  :null => false
    t.string "message",     :null => false
    t.string "name",        :null => false
    t.string "caption",     :null => false
    t.text   "description", :null => false
    t.string "locale",      :null => false
  end

  create_table "whowish_words", :force => true do |t|
    t.string "page_name", :null => false
    t.string "page_id",   :null => false
    t.string "word_id",   :null => false
    t.text   "content",   :null => false
    t.string "locale",    :null => false
  end

end
