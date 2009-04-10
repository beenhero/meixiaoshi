class Address < ActiveRecord::Base
  belongs_to  :addressable, :polymorphic => true
  belongs_to  :province
  belongs_to  :city
  belongs_to  :county
  belongs_to  :area
  
  validates_presence_of :addressable_id,
                        :addressable_type,
                        :city
  
  def single_name
    return street unless street.blank?
    return area.name if area
    return county.name if county
    return city.name if city
    return province.name if province
  end
  
  def single_line
    multi_line.join('')
  end
  
  def multi_line
    lines = []
    lines << province.name if province
    lines << city.name if city
    lines << county.name if county
    lines << area.name if area
    lines << street if street
    lines
  end

end
