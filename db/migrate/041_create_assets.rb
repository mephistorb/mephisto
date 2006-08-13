class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      t.column "width", :integer  
      t.column "height", :integer
      
      t.column :site_id, :integer
      t.column :created_at, :datetime
      t.column :title, :string
    end
  end

  def self.down
    drop_table :assets
  end
end
