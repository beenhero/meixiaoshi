class CreateUserInfo < ActiveRecord::Migration
  def self.up
    create_table :user_info, :force => true do |t|
      t.references :user, :null => false
      t.date :birthday
      t.string :gender, :default => ''
      t.string :real_name, :default => ''
      t.text :bio, :default => ''
      t.timestamps
    end
    add_index :user_info, :user_id
  end

  def self.down
    drop_table :user_info
  end
end
