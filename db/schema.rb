# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_13_002630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "street_1", default: "", null: false
    t.string "street_2", default: "", null: false
    t.string "city", default: "", null: false
    t.string "state", default: "", null: false
    t.string "zip_code", default: "27502", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "address_id"
    t.index ["address_id"], name: "index_courses_on_address_id"
    t.index ["name"], name: "index_courses_on_name", unique: true
  end

  create_table "holes", force: :cascade do |t|
    t.integer "number", default: 0, null: false
    t.integer "yardage", default: 0, null: false
    t.integer "par", default: 0, null: false
    t.integer "hdcp", default: 0, null: false
    t.bigint "tee_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tee_id"], name: "index_holes_on_tee_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.date "date", default: "2021-01-07", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "score_holes", force: :cascade do |t|
    t.bigint "score_id"
    t.bigint "hole_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["hole_id"], name: "index_score_holes_on_hole_id"
    t.index ["score_id"], name: "index_score_holes_on_score_id"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "hole_number", default: 0, null: false
    t.integer "strokes", default: 0, null: false
    t.integer "putts", default: 0, null: false
    t.string "penalties", default: "", null: false
    t.bigint "round_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["round_id"], name: "index_scores_on_round_id"
  end

  create_table "tees", force: :cascade do |t|
    t.string "color", default: "White", null: false
    t.decimal "rating", null: false
    t.decimal "slope", null: false
    t.bigint "course_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["color", "course_id"], name: "index_tees_on_color_and_course_id", unique: true
    t.index ["course_id"], name: "index_tees_on_course_id"
  end

  add_foreign_key "courses", "addresses"
end
