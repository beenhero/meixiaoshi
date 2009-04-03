class UserInfo < ActiveRecord::Base
  set_table_name :user_info
  belongs_to :user
end