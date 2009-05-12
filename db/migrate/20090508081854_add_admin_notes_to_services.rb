class AddAdminNotesToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :admin_notes, :string
  end

  def self.down
    remove_column :services, :admin_notes
  end
end
