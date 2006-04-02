ActiveRecord::Schema.define(:version => 0) do
  create_table :attachments, :force => true do |t|
    t.column :db_file_id,      :integer
    t.column :parent_id,       :integer
    t.column :filename,        :string, :limit => 255
    t.column :content_type,    :string, :limit => 255
    t.column :size,            :integer
    t.column :width,           :integer
    t.column :height,          :integer
  end

  create_table :file_attachments, :force => true do |t|
    t.column :db_file_id,      :integer
    t.column :parent_id,       :integer
    t.column :filename,        :string, :limit => 255
    t.column :content_type,    :string, :limit => 255
    t.column :size,            :integer
    t.column :width,           :integer
    t.column :height,          :integer
    t.column :type,            :string
  end

  create_table :db_files, :force => true do |t|
    t.column :data, :binary
  end
end