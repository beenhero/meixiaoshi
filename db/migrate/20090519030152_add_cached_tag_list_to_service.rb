class AddCachedTagListToService < ActiveRecord::Migration
  def self.up
    add_column :services, :cached_tag_list, :string
  end

  def self.down
    remove_column :services, :cached_tag_list
  end
end
