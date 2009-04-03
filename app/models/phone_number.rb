class PhoneNumber < ActiveRecord::Base
  IM_TYPES = %w( QQ MSN Gtalk Skype 旺旺 雅虎通 )
  PHONE_TYPES = %w( 手机 电话 )
  SNS_TYPES = %w( 博客 主页 Twitter Facebook Fanfou Taotao)
  
  belongs_to :phoneable, :polymorphic => true
  validates_presence_of :name, :contact_type, :value, :phoneable_type, :phoneable_id

  protected
  def disassemble_number
    self.area_code = number[0,3]
    self.prefix = number[3,3]
    self.suffix = number[6,4]
  end

  def strip_phone
    self.number = self.number.gsub(/\D/, '') if self.number
    self.name = 'home' if self.name.blank?
  end
end