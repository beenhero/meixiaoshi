class AddSpammerAndAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :spammer, :boolean, :default => false
  end

  def self.down
    remove_column :users, :spammer
    remove_column :users, :admin
  end
end
