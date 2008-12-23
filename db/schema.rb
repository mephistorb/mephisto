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

ActiveRecord::Schema.define(:version => 20081223221228) do

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
    t.integer  "site_id"
    t.datetime "created_at"
    t.string   "title"
    t.integer  "thumbnails_count", :default => 0
    t.integer  "user_id"
  end

  create_table "assigned_assets", :force => true do |t|
    t.integer  "article_id"
    t.integer  "asset_id"
    t.integer  "position"
    t.string   "label"
    t.datetime "created_at"
    t.boolean  "active"
  end

  create_table "assigned_sections", :force => true do |t|
    t.integer "article_id"
    t.integer "section_id"
    t.integer "position",   :default => 1
  end

  add_index "assigned_sections", ["article_id", "section_id"], :name => "idx_a_sections_article_section"

  create_table "cached_pages", :force => true do |t|
    t.string   "url"
    t.text     "references"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.datetime "cleared_at"
  end

  create_table "content_versions", :force => true do |t|
    t.integer  "content_id"
    t.integer  "version"
    t.integer  "article_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "permalink"
    t.text     "excerpt"
    t.text     "body"
    t.text     "excerpt_html"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "author",         :limit => 100
    t.string   "author_url"
    t.string   "author_email"
    t.string   "author_ip",      :limit => 100
    t.integer  "comments_count",                :default => 0
    t.integer  "updater_id"
    t.string   "versioned_type", :limit => 20
    t.integer  "site_id"
    t.boolean  "approved",                      :default => false
    t.integer  "comment_age",                   :default => 0
    t.string   "filter"
    t.string   "user_agent"
    t.string   "referrer"
    t.integer  "assets_count",                  :default => 0
  end

  create_table "contents", :force => true do |t|
    t.integer  "article_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "permalink"
    t.text     "excerpt"
    t.text     "body"
    t.text     "excerpt_html"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "type",           :limit => 20
    t.string   "author",         :limit => 100
    t.string   "author_url"
    t.string   "author_email"
    t.string   "author_ip",      :limit => 100
    t.integer  "comments_count",                :default => 0
    t.integer  "updater_id"
    t.integer  "version"
    t.integer  "site_id"
    t.boolean  "approved",                      :default => false
    t.integer  "comment_age",                   :default => 0
    t.string   "filter"
    t.string   "user_agent"
    t.string   "referrer"
    t.integer  "assets_count",                  :default => 0
  end

  add_index "contents", ["article_id", "approved", "type"], :name => "idx_comments"
  add_index "contents", ["published_at"], :name => "idx_articles_published"

  create_table "events", :force => true do |t|
    t.string   "mode"
    t.integer  "user_id"
    t.integer  "article_id"
    t.text     "title"
    t.text     "body"
    t.datetime "created_at"
    t.string   "author",     :limit => 100
    t.integer  "comment_id"
    t.integer  "site_id"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "email"
    t.text     "body"
    t.string   "key"
    t.datetime "created_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.boolean  "admin",      :default => false
  end

  create_table "mephisto_plugins", :force => true do |t|
    t.string "name"
    t.text   "options"
    t.string "type"
  end

  create_table "sections", :force => true do |t|
    t.string  "name"
    t.boolean "show_paged_articles", :default => false
    t.integer "articles_per_page",   :default => 15
    t.string  "layout"
    t.string  "template"
    t.integer "site_id"
    t.string  "path"
    t.integer "articles_count",      :default => 0
    t.string  "archive_path"
    t.string  "archive_template"
    t.integer "position",            :default => 1
  end

  create_table "sites", :force => true do |t|
    t.string  "title"
    t.string  "subtitle"
    t.string  "email"
    t.text    "ping_urls"
    t.integer "articles_per_page",                 :default => 15
    t.string  "host"
    t.boolean "approve_comments"
    t.integer "comment_age"
    t.string  "timezone"
    t.string  "filter",                            :default => "textile_filter"
    t.string  "permalink_style"
    t.string  "search_path"
    t.string  "tag_path"
    t.string  "tag_layout"
    t.string  "current_theme_path"
    t.string  "akismet_key",        :limit => 100
    t.string  "akismet_url"
    t.string  "lang",                              :default => "en-US",          :null => false
  end

  add_index "sites", ["host"], :name => "index_sites_on_host"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login",            :limit => 40
    t.string   "email",            :limit => 100
    t.string   "crypted_password", :limit => 40
    t.string   "salt",             :limit => 40
    t.string   "activation_code",  :limit => 40
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "token_expires_at"
    t.string   "filter",                          :default => "textile_filter"
    t.boolean  "admin",                           :default => false
  end

end
