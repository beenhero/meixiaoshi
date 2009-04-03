class City < ActiveRecord::Base
  belongs_to :province
  has_many :counties
  
  # Get the province's cities
  def self.city_options(parent_id = nil)
    find(:all, :conditions => { :province_id => parent_id }).collect{|c| [c.name, c.id]}
  end
  
end