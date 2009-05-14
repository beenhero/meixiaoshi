class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :service_id
      t.integer :user_id
      t.integer :buyer_id
      t.string :buyer_name
      t.string :phone
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
