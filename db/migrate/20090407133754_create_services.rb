class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services, :force => true do |t|
      t.integer :user_id, :null => false
      t.integer :price, :radius
      t.string :name, :location, :repeat_cycle, :repeat_type, :price_unit, :repeat_kinds
      t.text :description
      t.integer :repeat_every
      t.datetime :begin_date_time, :end_date_time
      t.date :repeat_until
      t.boolean :is_recurring, :is_all_day, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
      
      t.timestamps
    end
    
    add_index :services, :user_id
    add_index :services, :name
    add_index :services, :location
    add_index :services, :begin_date_time
    
    create_table :schedules do |t|
      t.integer :service_id
      t.datetime :begin_date_time, :end_date_time
      
      t.timestamps
    end
    
    add_index :schedules, [:service_id, :begin_date_time]
    add_index :schedules, :begin_date_time
  end

  def self.down
    drop_table :schedules
    drop_table :services
  end
end
