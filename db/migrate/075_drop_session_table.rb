class DropSessionTable < ActiveRecord::Migration
  def self.up
    remove_index :sessions, :name => :sessions_session_id_index
    drop_table :sessions
  end

  def self.down
    create_table "sessions", :force => true do |t|
      t.string   "session_id"
      t.text     "data"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"
  end
end
