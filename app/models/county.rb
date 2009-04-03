class County < ActiveRecord::Base
  belongs_to :city
  has_many :areas
  
  # Get the city's counties
  def self.county_options(parent_id = nil)
    find(:all, :conditions => { :city_id => parent_id }).collect{|c| [c.name, c.id]}
  end
  
end