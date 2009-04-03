class Province < ActiveRecord::Base
  has_many :cities
  
  def self.province_options
    find(:all).collect{|p| [p.name, p.id]}
  end
  
  def city_options
    self.cities.collect{|c| [c.name, c.id]}
  end
end