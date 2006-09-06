class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.column :site_id, :integer
      t.column :user_id, :integer
      t.column :created_at, :datetime
      t.column :admin, :boolean, :default => false
    end
  end

  def self.down
    drop_table :memberships
  end
end
