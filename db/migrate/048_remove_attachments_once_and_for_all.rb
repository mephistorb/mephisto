class RemoveAttachmentsOnceAndForAll < ActiveRecord::Migration
  def self.up
    drop_table "attachments"
  end

  def self.down
    create_table "attachments", :force => true do |t|
      t.column "type",            :string,  :limit => 15
      t.column "content_type",    :string,  :limit => 100
      t.column "filename",        :string
      t.column "db_file_id",      :integer
      t.column "parent_id",       :integer
      t.column "size",            :integer
      t.column "width",           :integer
      t.column "height",          :integer
      t.column "attachable_id",   :integer
      t.column "attachable_type", :string,  :limit => 20
      t.column "site_id",         :integer
    end
  end
end
