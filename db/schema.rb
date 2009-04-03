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

ActiveRecord::Schema.define(:version => 20090330134111) do

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id",                   :null => false
    t.string   "addressable_type",                 :null => false
    t.string   "street",           :default => ""
    t.integer  "area_id"
    t.integer  "county_id"
    t.integer  "city_id"
    t.integer  "province_id"
    t.string   "postal_code",      :default => ""
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_type", "addressable_id"], :name => "index_addresses_on_addressable_type_and_addressable_id"
  add_index "addresses", ["street"], :name => "index_addresses_on_street"

  create_table "areas", :force => true do |t|
    t.integer "county_id"
    t.string  "name",      :null => false
  end

  add_index "areas", ["name"], :name => "index_areas_on_name"

  create_table "cities", :force => true do |t|
    t.integer "province_id"
    t.string  "name",        :null => false
  end

  add_index "cities", ["name"], :name => "index_cities_on_name"

  create_table "counties", :force => true do |t|
    t.integer "city_id"
    t.string  "name",    :null => false
  end

  add_index "counties", ["name"], :name => "index_counties_on_name"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer  "phonable_id",   :null => false
    t.string   "phonable_type", :null => false
    t.string   "name",          :null => false
    t.string   "contact_type",  :null => false
    t.string   "value",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_numbers", ["phonable_type", "phonable_id"], :name => "index_phone_numbers_on_phonable_type_and_phonable_id"

  create_table "provinces", :force => true do |t|
    t.string "name",                         :null => false
    t.string "abbreviation", :default => ""
  end

  add_index "provinces", ["abbreviation"], :name => "index_provinces_on_abbreviation"
  add_index "provinces", ["name"], :name => "index_provinces_on_name"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_info", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.date     "birthday"
    t.string   "gender",     :default => ""
    t.string   "real_name",  :default => ""
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_info", ["user_id"], :name => "index_user_info_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "identity_url"
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                    :default => "passive", :null => false
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
