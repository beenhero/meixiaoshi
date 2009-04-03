class Address < ActiveRecord::Base
  belongs_to  :addressable, :polymorphic => true
  belongs_to  :province
  belongs_to  :city
  belongs_to  :county
  belongs_to  :area
  
  validates_presence_of :addressable_id,
                        :addressable_type,
                        :city
  
  DISTRICT_OPTIONS = [
    ['上城区', '上城区']
  ]
  # def single_line
  #   multi_line.join(', ')
  # end
  # 
  # def multi_line
  #   lines = []
  #   lines << street_1 if street_1?
  #   lines << street_2 if street_2?
  #   
  #   line = ''
  #   line << city if city?
  #   if region_name
  #     line << ', ' unless line.blank?
  #     line << region_name
  #   end
  #   if postal_code?
  #     line << '  ' unless line.blank?
  #     line << postal_code
  #   end
  #   lines << line unless line.blank?
  #   
  #   lines << country.name if country
  #   lines
  # end

end
