class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :service_id
      t.integer :user_id
      t.integer :buyer_id
      t.string :name
      t.string :email
      t.string :phone
      t.text :description
      t.text :reply
      t.datetime :replied_at
      t.datetime :created_at
      t.datetime :deleted_at
    end
  end

  def self.down
    drop_table :orders
  end
end
