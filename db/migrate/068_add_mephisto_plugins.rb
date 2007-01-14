class AddMephistoPlugins < ActiveRecord::Migration
  def self.up
    create_table :mephisto_plugins do |t|
      t.column :name, :string
      t.column :options, :text
      t.column :type, :string
    end
  end

  def self.down
    drop_table :mephisto_plugins
  end
end