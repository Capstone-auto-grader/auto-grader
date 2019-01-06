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

ActiveRecord::Schema.define(version: 2019_01_06_031629) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string "name"
    t.string "assignment_test"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "test_uri"
    t.bigint "course_id"
    t.text "structure"
    t.integer "test_grade_weight"
    t.integer "resubmit_id"
    t.index ["course_id"], name: "index_assignments_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachment"
    t.string "zip_uri"
    t.bigint "assignment_id"
    t.integer "latte_id"
    t.integer "tests_passed"
    t.integer "total_tests"
    t.decimal "ta_grade"
    t.integer "ta_id"
    t.text "ta_comment"
    t.integer "student_id"
    t.integer "resubmission_id"
    t.boolean "grade_received"
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
    t.index ["latte_id"], name: "index_submissions_on_latte_id"
  end

  create_table "t_as_classes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ta_conflicts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "conflict_id"
    t.index ["conflict_id"], name: "index_ta_conflicts_on_conflict_id"
    t.index ["user_id"], name: "index_ta_conflicts_on_user_id"
  end

  create_table "takes_classes", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "student_id"
  end

  create_table "teaches_classes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "name"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_foreign_key "ta_conflicts", "users"
  add_foreign_key "ta_conflicts", "users", column: "conflict_id"
end
