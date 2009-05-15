class Order < ActiveRecord::Base
  belongs_to :service
  belongs_to :user
  validates_presence_of :phone, :email
  
  named_scope :valid, :conditions => ["deleted_at is NULL"]
  
  def replied?
    !replied_at.nil?
  end
  
end
