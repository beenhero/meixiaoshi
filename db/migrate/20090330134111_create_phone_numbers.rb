class CreatePhoneNumbers < ActiveRecord::Migration
  def self.up
    create_table :phone_numbers, :force => true do |t|
      t.references :phonable, :polymorphic => true, :null => false
      t.string :name, :null => false
      t.string :contact_type, :null => false
      t.string :value, :null => false
      t.timestamps
    end
    add_index :phone_numbers, [:phonable_type, :phonable_id]
  end

  def self.down
    drop_table :phone_numbers
  end
end
