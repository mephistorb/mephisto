class AddAttachable < ActiveRecord::Migration
  def self.up
    add_column   :assets, :attachable_id,   :integer
    add_column   :assets, :attachable_type, :string, :limit => 20
    rename_table :assets, :attachments
  end

  def self.down
    rename_table  :attachments, :assets
    remove_column :assets,      :attachable_id
    remove_column :assets,      :attachable_type
  end
end
