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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130207193730) do

  create_table "deploys", :force => true do |t|
    t.string   "git_ref"
    t.string   "commit_user"
    t.string   "commit_message"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "project_id"
    t.string   "deploy_status"
    t.datetime "commit_time"
    t.datetime "build_time"
  end

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "status"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "github_repository"
    t.string   "jenkins_url"
    t.string   "s3_bucket"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "build_step"
    t.string   "build_dir"
    t.string   "branch"
    t.boolean  "webhook"
    t.string   "project_type"
  end

  create_table "projects_users", :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "project_id", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "name"
    t.string   "email"
    t.string   "oauth_token"
    t.string   "uid"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "github_username"
    t.string   "reno_token"
    t.string   "image"
  end

  add_foreign_key "deploys", "projects", :name => "deploys_project_id_fk"

  add_foreign_key "messages", "projects", :name => "messages_project_id_fk"
  add_foreign_key "messages", "users", :name => "messages_user_id_fk"

  add_foreign_key "projects_users", "projects", :name => "projects_users_project_id_fk"
  add_foreign_key "projects_users", "users", :name => "projects_users_user_id_fk"

end
