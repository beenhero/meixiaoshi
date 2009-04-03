class Area < ActiveRecord::Base
  belongs_to :county
  
  # Get the county's areas
  def self.area_options(parent_id = nil)
    find(:all, :conditions => { :county_id => parent_id }).collect{|c| [c.name, c.id]}
  end
  
end