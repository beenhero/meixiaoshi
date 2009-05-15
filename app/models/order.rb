class Order < ActiveRecord::Base
  belongs_to :service
  belongs_to :user
  belongs_to :buyer, :class_name => 'User'
  validates_presence_of :phone, :email
  
  named_scope :valid, :conditions => ["deleted_at is NULL"]
  named_scope :unreplied, :conditions => ["replied_at is NULL"]
  named_scope :deleted, :conditions => ["deleted_at is NOT NULL"]
  named_scope :delayed, :conditions => ["replied_at is NULL and created_at < ?", Time.now - 2.hours]
  
  def replied?
    !replied_at.nil?
  end
  
end
