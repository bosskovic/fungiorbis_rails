# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141128173116) do

  create_table "characteristics", force: true do |t|
    t.integer  "reference_id",  null: false
    t.integer  "species_id",    null: false
    t.boolean  "edible"
    t.boolean  "cultivated"
    t.boolean  "poisonous"
    t.boolean  "medicinal"
    t.text     "fruiting_body"
    t.text     "microscopy"
    t.text     "flesh"
    t.text     "chemistry"
    t.text     "note"
    t.text     "habitats"
    t.text     "substrates"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "characteristics", ["reference_id"], name: "index_characteristics_on_reference_id", using: :btree
  add_index "characteristics", ["species_id"], name: "index_characteristics_on_species_id", using: :btree
  add_index "characteristics", ["uuid"], name: "index_characteristics_on_uuid", unique: true, using: :btree

  create_table "locations", force: true do |t|
    t.string   "name",       null: false
    t.string   "utm",        null: false
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["uuid"], name: "index_locations_on_uuid", unique: true, using: :btree

  create_table "references", force: true do |t|
    t.string   "title",      null: false
    t.string   "authors"
    t.string   "isbn"
    t.string   "url"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "references", ["uuid"], name: "index_references_on_uuid", unique: true, using: :btree

  create_table "species", force: true do |t|
    t.string   "name",            null: false
    t.string   "genus",           null: false
    t.string   "familia",         null: false
    t.string   "ordo",            null: false
    t.string   "subclassis",      null: false
    t.string   "classis",         null: false
    t.string   "subphylum",       null: false
    t.string   "phylum",          null: false
    t.text     "synonyms"
    t.string   "growth_type"
    t.string   "nutritive_group"
    t.string   "url"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "species", ["name", "genus"], name: "index_species_on_name_and_genus", using: :btree
  add_index "species", ["url"], name: "index_species_on_url", unique: true, using: :btree
  add_index "species", ["uuid"], name: "index_species_on_uuid", unique: true, using: :btree

  create_table "specimen", force: true do |t|
    t.integer  "species_id",        null: false
    t.integer  "location_id",       null: false
    t.integer  "legator_id",        null: false
    t.string   "legator_text"
    t.integer  "determinator_id"
    t.string   "determinator_text"
    t.text     "habitats"
    t.text     "substrates"
    t.date     "date",              null: false
    t.text     "quantity"
    t.text     "note"
    t.boolean  "approved"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "specimen", ["determinator_id"], name: "index_specimen_on_determinator_id", using: :btree
  add_index "specimen", ["legator_id"], name: "index_specimen_on_legator_id", using: :btree
  add_index "specimen", ["location_id"], name: "index_specimen_on_location_id", using: :btree
  add_index "specimen", ["species_id"], name: "index_specimen_on_species_id", using: :btree
  add_index "specimen", ["uuid"], name: "index_specimen_on_uuid", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                   null: false
    t.string   "encrypted_password"
    t.string   "first_name",                              null: false
    t.string   "last_name",                               null: false
    t.string   "title"
    t.string   "role",                   default: "user", null: false
    t.string   "institution"
    t.string   "phone"
    t.string   "uuid"
    t.string   "authentication_token"
    t.datetime "deactivated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

end
