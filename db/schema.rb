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

ActiveRecord::Schema.define(:version => 20100207005723) do

  create_table "addresses", :force => true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "line3"
    t.string   "city"
    t.string   "state"
    t.string   "postcode"
    t.string   "country",          :limit => 2
    t.string   "phone"
    t.boolean  "isvalid"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                  :default => 0
  end

  create_table "answers", :force => true do |t|
    t.integer  "Survey_id"
    t.string   "question"
    t.text     "reply"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "event_assignments", :force => true do |t|
    t.integer  "person_id"
    t.integer  "event_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "events", :force => true do |t|
    t.string   "short_title"
    t.string   "title"
    t.text     "precis"
    t.integer  "duration"
    t.integer  "minimum_people"
    t.integer  "maximum_people"
    t.string   "format"
    t.text     "notes"
    t.boolean  "print"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",   :default => 0
  end

  create_table "exclusions", :force => true do |t|
    t.integer  "excludable_id"
    t.string   "excludable_type"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",    :default => 0
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "email"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "registration_details", :force => true do |t|
    t.integer  "Person_id"
    t.string   "registration_number"
    t.string   "registration_type"
    t.boolean  "registered"
    t.boolean  "ghost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",        :default => 0
  end

  create_table "relationships", :force => true do |t|
    t.integer  "relatable_id"
    t.string   "relatable_type"
    t.integer  "person_id"
    t.string   "relationship_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",      :default => 0
  end

  create_table "rooms", :force => true do |t|
    t.integer  "venue_id"
    t.text     "string"
    t.integer  "capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "schedules", :force => true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "surveys", :force => true do |t|
    t.integer  "Person_id"
    t.text     "notes"
    t.boolean  "can_interview"
    t.boolean  "hugo_nominee"
    t.boolean  "volunteer"
    t.datetime "arrival_time"
    t.datetime "departure_time"
    t.integer  "max_items"
    t.integer  "max_items_per_day"
    t.integer  "nbr_panels_moderated"
    t.string   "homepage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",         :default => 0
  end

  create_table "tags", :force => true do |t|
    t.integer  "tagable_id"
    t.string   "tagable_type"
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "terms", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "time_slots", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.string   "type"
    t.integer  "schedule_id_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",   :default => 0
  end

  create_table "venues", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

end
