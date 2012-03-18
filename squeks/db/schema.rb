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

ActiveRecord::Schema.define(:version => 20110621054531) do

  create_table "bid_requests", :force => true do |t|
    t.integer  "facebook_id",  :limit => 8, :null => false
    t.integer  "figure_id",                 :null => false
    t.integer  "value"
    t.string   "status"
    t.datetime "created_date"
  end

  create_table "comment_agrees", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "facebook_id",  :limit => 8,                    :null => false
    t.string   "agree_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",              :default => false, :null => false
  end

  create_table "comment_pendings", :force => true do |t|
    t.string "status"
    t.text   "data"
    t.string "unique_key"
  end

  create_table "comments", :force => true do |t|
    t.integer  "figure_id"
    t.integer  "facebook_id",  :limit => 8,                       :null => false
    t.datetime "created_date"
    t.text     "comment"
    t.integer  "agrees",                    :default => 0,        :null => false
    t.integer  "disagrees",                 :default => 0,        :null => false
    t.integer  "parent_id",                 :default => 0,        :null => false
    t.boolean  "is_anonymous",              :default => false,    :null => false
    t.integer  "total_agree",               :default => 0,        :null => false
    t.string   "status",                    :default => "ACTIVE", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string "name", :null => false
    t.string "code", :null => false
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

  create_table "discussion_comment_agrees", :force => true do |t|
    t.integer  "discussion_comment_id"
    t.integer  "facebook_id",           :limit => 8,                    :null => false
    t.string   "agree_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",                       :default => false, :null => false
  end

  create_table "discussion_comments", :force => true do |t|
    t.integer  "discussion_id"
    t.integer  "facebook_id",   :limit => 8,                    :null => false
    t.datetime "created_date"
    t.text     "comment"
    t.integer  "agrees",                     :default => 0,     :null => false
    t.integer  "disagrees",                  :default => 0,     :null => false
    t.integer  "parent_id",                  :default => 0,     :null => false
    t.boolean  "is_anonymous",               :default => false, :null => false
    t.integer  "total_agree",                :default => 0,     :null => false
    t.string   "status"
  end

  create_table "discussion_figures", :force => true do |t|
    t.integer  "discussion_id", :null => false
    t.integer  "figure_id",     :null => false
    t.datetime "created_date"
  end

  create_table "discussion_hour_counts", :primary_key => "guid", :force => true do |t|
    t.date    "date"
    t.integer "hour"
    t.integer "discussion_id"
    t.integer "loves"
    t.integer "hates"
  end

  create_table "discussion_love_pendings", :force => true do |t|
    t.string "status"
    t.text   "data"
    t.string "unique_key"
  end

  create_table "discussion_loves", :force => true do |t|
    t.integer  "discussion_id",                                 :null => false
    t.integer  "facebook_id",   :limit => 8,                    :null => false
    t.string   "love_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",               :default => false, :null => false
  end

  create_table "discussion_pendings", :force => true do |t|
    t.string "status"
    t.text   "data"
    t.string "unique_key"
  end

  create_table "discussions", :force => true do |t|
    t.string   "title",                                               :null => false
    t.text     "description"
    t.datetime "created_date"
    t.string   "status"
    t.integer  "loves",                            :default => 0,     :null => false
    t.integer  "hates",                            :default => 0,     :null => false
    t.integer  "views",                            :default => 0,     :null => false
    t.integer  "dont_cares",                       :default => 0,     :null => false
    t.integer  "replies",                                             :null => false
    t.integer  "creator_facebook_id", :limit => 8,                    :null => false
    t.boolean  "is_anonymous",                     :default => false, :null => false
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
    t.integer  "friend_count"
  end

  add_index "facebook_friend_caches", ["facebook_id"], :name => "facebook_id", :unique => true

  create_table "feeds", :force => true do |t|
    t.datetime "created_date",                 :null => false
    t.integer  "facebook_id",     :limit => 8
    t.integer  "figure_id"
    t.integer  "comment_id"
    t.integer  "figure_image_id"
    t.string   "action"
    t.text     "data"
    t.boolean  "is_anonymous"
    t.integer  "bid_request_id"
    t.integer  "discussion_id"
  end

  create_table "figure_image_likes", :force => true do |t|
    t.integer  "figure_image_id"
    t.integer  "facebook_id",     :limit => 8,                    :null => false
    t.string   "like_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",                 :default => false, :null => false
  end

  create_table "figure_images", :force => true do |t|
    t.integer "figure_id"
    t.string  "original_image_path"
    t.integer "ordered_number"
    t.integer "likes",               :default => 0, :null => false
    t.integer "dislikes",            :default => 0, :null => false
  end

  create_table "figure_love_pendings", :force => true do |t|
    t.string "status"
    t.text   "data"
    t.string "unique_key"
  end

  create_table "figure_loves", :force => true do |t|
    t.integer  "figure_id"
    t.integer  "facebook_id",  :limit => 8,                    :null => false
    t.string   "love_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",              :default => false, :null => false
  end

  create_table "figure_tags", :force => true do |t|
    t.integer "figure_id"
    t.integer "tag_id"
    t.string  "title_us"
    t.string  "title_th"
    t.string  "title_jp"
    t.string  "title_kr"
    t.string  "title_cn"
  end

  create_table "figures", :force => true do |t|
    t.string   "title_us",                                                :null => false
    t.text     "description"
    t.string   "default_pic"
    t.datetime "created_date"
    t.string   "status"
    t.integer  "loves",                            :default => 0,         :null => false
    t.integer  "hates",                            :default => 0,         :null => false
    t.integer  "dont_cares",                       :default => 0,         :null => false
    t.integer  "views",                            :default => 0,         :null => false
    t.integer  "creator_facebook_id", :limit => 8
    t.string   "country_code"
    t.string   "title_th"
    t.string   "title_jp"
    t.string   "title_kr"
    t.string   "title_cn"
    t.text     "tags"
    t.integer  "value",                            :default => 1,         :null => false
    t.integer  "manager_facebook_id", :limit => 8, :default => 0,         :null => false
    t.datetime "bid_start_time"
    t.string   "bid_status",                       :default => "SETTLED", :null => false
    t.string   "zip_file_path"
    t.string   "reason"
  end

  create_table "flags", :force => true do |t|
    t.integer  "figure_id"
    t.integer  "comment_id"
    t.integer  "facebook_id",  :limit => 8, :null => false
    t.datetime "created_date"
    t.string   "flag_type"
    t.text     "reason"
  end

  create_table "forbidden_words", :force => true do |t|
    t.string "word"
  end

  create_table "friend_caches", :force => true do |t|
    t.integer  "crypto_id",    :null => false
    t.text     "friends",      :null => false
    t.datetime "updated_date", :null => false
  end

  create_table "history_comments", :force => true do |t|
    t.integer  "figure_id"
    t.integer  "facebook_id",  :limit => 8,                    :null => false
    t.datetime "created_date"
    t.text     "comment"
    t.integer  "agrees",                    :default => 0,     :null => false
    t.integer  "disagrees",                 :default => 0,     :null => false
    t.integer  "parent_id",                 :default => 0,     :null => false
    t.boolean  "is_anonymous",              :default => false, :null => false
    t.integer  "total_agree"
    t.string   "status"
  end

  create_table "history_figure_loves", :force => true do |t|
    t.integer  "figure_id"
    t.integer  "facebook_id",  :limit => 8,                    :null => false
    t.string   "love_type"
    t.datetime "created_date"
    t.boolean  "is_anonymous",              :default => false, :null => false
  end

  create_table "history_figure_pictures", :force => true do |t|
    t.integer "figure_id"
    t.string  "original_image_path"
    t.integer "ordered_number"
    t.integer "likes"
    t.integer "dislikes"
  end

  create_table "history_figure_tags", :force => true do |t|
    t.integer "figure_id"
    t.integer "tag_id"
    t.string  "title_us"
    t.string  "title_th"
    t.string  "title_jp"
    t.string  "title_kr"
    t.string  "title_cn"
  end

  create_table "history_figures", :force => true do |t|
    t.string   "title_us",                                                :null => false
    t.string   "description"
    t.string   "default_pic"
    t.datetime "created_date"
    t.string   "status"
    t.integer  "loves",                            :default => 0,         :null => false
    t.integer  "hates",                            :default => 0,         :null => false
    t.integer  "dont_cares",                       :default => 0,         :null => false
    t.integer  "views",                            :default => 0,         :null => false
    t.integer  "main_figure_id",                                          :null => false
    t.string   "title_th"
    t.string   "title_jp"
    t.string   "title_kr"
    t.string   "title_cn"
    t.text     "tags"
    t.integer  "value",                            :default => 1,         :null => false
    t.integer  "manager_facebook_id", :limit => 8, :default => 0,         :null => false
    t.integer  "creator_facebook_id", :limit => 8, :default => 0,         :null => false
    t.datetime "bid_start_time"
    t.string   "bid_status",                       :default => "SETTLED", :null => false
    t.string   "zip_file_path"
    t.string   "country_code"
  end

  create_table "languages", :force => true do |t|
    t.string "name", :null => false
    t.string "code", :null => false
  end

  create_table "locks", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "facebook_id",               :limit => 8,                       :null => false
    t.string   "name",                                                         :null => false
    t.string   "gender",                                                       :null => false
    t.string   "anonymous_name",                                               :null => false
    t.string   "anonymous_profile_pic",                                        :null => false
    t.boolean  "is_anonymous",                           :default => false,    :null => false
    t.boolean  "is_share_love",                          :default => false,    :null => false
    t.boolean  "is_share_hate",                          :default => false,    :null => false
    t.boolean  "is_share_comment",                       :default => false,    :null => false
    t.boolean  "is_share_comment_agree",                 :default => false,    :null => false
    t.boolean  "is_share_comment_disagree",              :default => false,    :null => false
    t.datetime "updated_date"
    t.integer  "credits",                                :default => 0,        :null => false
    t.string   "country_code"
    t.boolean  "is_aesir",                               :default => false,    :null => false
    t.string   "status",                                 :default => "ACTIVE", :null => false
  end

  create_table "notifications", :force => true do |t|
    t.datetime "created_date",                                         :null => false
    t.integer  "notified_facebook_id", :limit => 8,                    :null => false
    t.integer  "facebook_id",          :limit => 8,                    :null => false
    t.integer  "comment_id"
    t.string   "action"
    t.text     "data"
    t.boolean  "is_anonymous"
    t.integer  "figure_id"
    t.integer  "bid_request_id"
    t.boolean  "is_read",                           :default => false, :null => false
  end

  create_table "share_logs", :force => true do |t|
    t.string   "type"
    t.integer  "facebook_id",  :limit => 8
    t.datetime "created_date"
  end

  create_table "share_tickets", :force => true do |t|
    t.string   "unique_key"
    t.string   "permission"
    t.datetime "created_date"
    t.datetime "finished_date"
    t.string   "status"
    t.string   "ref"
    t.text     "error_message"
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
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

  create_table "web_metrics_activities", :force => true do |t|
    t.string "controller"
    t.string "string"
    t.string "action"
    t.string "action_type"
  end

  create_table "web_trace_activity_hours", :force => true do |t|
    t.date    "date",                  :null => false
    t.integer "hour",                  :null => false
    t.string  "controller"
    t.string  "action"
    t.integer "guest_activity_count"
    t.integer "member_activity_count"
    t.integer "guest_count"
    t.integer "member_count"
  end

  create_table "web_trace_unique_user_days", :force => true do |t|
    t.date    "date",                               :null => false
    t.integer "unique_user_count",   :default => 0, :null => false
    t.integer "unique_ip_count",     :default => 0, :null => false
    t.integer "unique_member_count", :default => 0, :null => false
  end

  create_table "web_trace_unique_user_hours", :force => true do |t|
    t.date    "date",                               :null => false
    t.integer "hour",                               :null => false
    t.integer "unique_user_count",   :default => 0, :null => false
    t.integer "unique_ip_count",     :default => 0, :null => false
    t.integer "unique_member_count", :default => 0, :null => false
  end

  create_table "web_trace_unique_user_months", :force => true do |t|
    t.date    "date",                               :null => false
    t.integer "unique_user_count",   :default => 0, :null => false
    t.integer "unique_ip_count",     :default => 0, :null => false
    t.integer "unique_member_count", :default => 0, :null => false
  end

  create_table "web_trace_unique_user_weeks", :force => true do |t|
    t.date    "date",                               :null => false
    t.integer "unique_user_count",   :default => 0, :null => false
    t.integer "unique_ip_count",     :default => 0, :null => false
    t.integer "unique_member_count", :default => 0, :null => false
  end

  create_table "web_traces", :force => true do |t|
    t.string   "ip_address",                                   :null => false
    t.string   "unique_key",                                   :null => false
    t.datetime "time",                                         :null => false
    t.decimal  "fraction_time", :precision => 17, :scale => 6
    t.string   "controller",                                   :null => false
    t.string   "action",                                       :null => false
    t.string   "browser",                                      :null => false
    t.string   "member_id",                                    :null => false
    t.string   "referer",                                      :null => false
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

  add_index "whowish_words", ["word_id"], :name => "word_id", :unique => true

end
