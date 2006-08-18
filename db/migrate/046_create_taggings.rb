class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :taggable_type, :string
    end
  end

  def self.down
    drop_table :taggings
  end
end
