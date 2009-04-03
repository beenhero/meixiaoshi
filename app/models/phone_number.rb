class PhoneNumber < ActiveRecord::Base
  CONTACT_TYPES = {
    'PHONE' => [['手机', 'mobile'], ['电话', 'telphone']],
    'IM'    => [['QQ','qq'], ['MSN','msn'], ['Gtalk','gtalk'], ['Skype','skype'], 
                ['旺旺','wangwang'], ['雅虎通','yahoo']],
    'SNS'   => [['博客','blog'], ['主页','website'],['网店','shop'], ['Twitter','twitter'], ['Facebook','facebook']]
  }
  
  belongs_to :phonable, :polymorphic => true
  validates_presence_of :name, :contact_type, :phonable_type, :phonable_id
end