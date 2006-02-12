class OldTemplate < ActiveRecord::Base
  set_table_name 'templates'
end

class AddAssetsAndResources < ActiveRecord::Migration
  def self.up
    create_table :assets, :force => true do |t|
      t.column :type,         :string, :limit => 15
      t.column :content_type, :string, :limit => 100
      t.column :filename,     :string, :limit => 255
      t.column :path,         :string, :limit => 255
      t.column :db_file_id,   :integer
      t.column :parent_id,    :integer
      t.column :size,         :integer
      t.column :width,        :integer
      t.column :height,       :integer
    end

    create_table :db_files, :force => true do |t|
      t.column :data, :binary
    end
    
    Template.transaction do
      OldTemplate.find(:all).each { |temp| t = Template.new :attachment_data => temp.data, :filename => temp.name, :content_type => 'text/liquid' ; t.save! }
    end
    
    drop_table :templates
  end

  def self.down
    raise IrreversibleMigration
  end
end
