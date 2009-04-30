class AddStateToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :state, :string, :null => false, :default => 'passive'
    add_column :services, :activated_at, :datetime
    add_column :services, :deleted_at, :datetime
  end

  def self.down
    remove_colum :services, :deleted_at
    remove_colum :services, :activated_at
    remove_colum :services, :state
  end
end
