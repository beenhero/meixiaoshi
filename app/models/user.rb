require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  
  RESERVED = ['support', 'blog', 'www', 'billing', 'help', 'api', 'stage', 'venue', 'performer', 'event', 'concert', 'stage', 'meixiaoshi', 'signup', 'plans', 'signin', 'account', 'activate', 'users', 'profiles'
  ]
  
  # Validations
  validates_presence_of :login, :if => :not_using_openid?
  validates_length_of :login, :within => 3..40, :if => :not_using_openid?
  validates_uniqueness_of :login, :case_sensitive => false, :if => :not_using_openid?
  validates_format_of :login, :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD, :if => :not_using_openid?
  validates_exclusion_of :login, :in => RESERVED, :message => "登录名无效!"
  
  validates_format_of :name, :with => RE_NAME_OK, :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of :name, :maximum => 100
  validates_presence_of :email, :if => :not_using_openid?
  validates_length_of :email, :within => 6..100, :if => :not_using_openid?
  validates_uniqueness_of :email, :case_sensitive => false, :if => :not_using_openid?
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD, :if => :not_using_openid?
  validates_uniqueness_of :identity_url, :unless => :not_using_openid?
  validate :normalize_identity_url
  validates_acceptance_of :terms, :on => :create, :message => "你必须同意我们的服务条款才能注册。"
  
  # Relationships
  has_and_belongs_to_many :roles
  has_one  :address, :as => :addressable
  accepts_nested_attributes_for :address, :allow_destroy => true
  
  has_one :user_info
  accepts_nested_attributes_for :user_info, :allow_destroy => true
  
  has_many  :phone_numbers, :as => :phonable, :conditions => "contact_type = 'PHONE'"
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  
  has_many  :instant_messages, :as => :phonable, :class_name => 'PhoneNumber', :conditions => "contact_type = 'IM'"
  accepts_nested_attributes_for :instant_messages, :allow_destroy => true
  
  has_many  :snses, :as => :phonable, :class_name => 'PhoneNumber', :conditions => "contact_type = 'SNS'"
  accepts_nested_attributes_for :snses, :allow_destroy => true
  
  has_many  :services
  
  # User avatar setting by paperclip
  has_attached_file :avatar,
                    :styles => { :original => "<80x120", :thumb => "<48x48", :tiny => "24x24#" },
                    :default_url => "/images/default_avatars/:style.gif",
                    :url => "/assets/users/:id/:style/:basename.:extension",
                    :path => ":rails_root/public//assets/users/:id/:style/:basename.:extension"
  validates_attachment_size :avatar, :less_than => 5.megabytes
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :identity_url, :user_info_attributes, :phone_numbers_attributes, :instant_messages_attributes, :snses_attributes, :avatar, :terms
  
  attr_accessor :terms
  attr_reader :old_password
  
  
  class LoginError < RuntimeError ; end
    
  # set defaut to login if name isn't set.
  def to_s
    return self.name unless self.name.blank?
    return self.login unless self.login.blank? 
    return "Anonymous"
  end
  
  def to_param
    return self.login
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    if login.to_s.include?("@")
      u = first(:conditions => {:email => login})
    else
      u = first(:conditions => {:login => login})
    end
    if u && u.authenticated?(password)
      case u.state
      when "pending"
        raise LoginError, "请登录你的邮箱，激活帐号"
      when "suspended"
        raise LoginError, "你的帐号已被冻结，有关事宜请联系网站客服"
      when "deleted"
        raise LoginError, "你的帐号将被删除，有关事宜请联系网站客服"
      when "active"
        return u
      end
    else
      raise LoginError, "登录名或密码错误"
    end
  end
  
  # Check if a user has a role.
  def has_role?(role)
    list ||= self.roles.map(&:name)
    list.include?(role.to_s) || list.include?('admin')
  end
  
  # Not using open id
  def not_using_openid?
    identity_url.blank?
  end
  
  # Overwrite password_required for open id
  def password_required?
    new_record? ? not_using_openid? && (crypted_password.blank? || !password.blank?) : !password.blank?
  end
  
  def self.check_login?(login)
    user = User.new(:login => login)
    user.valid?
    user.errors.on(:login).blank?
  end
  
  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_login(args)
    else
      super
    end
  end
  
  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
  
  def normalize_identity_url
    self.identity_url = OpenIdAuthentication.normalize_url(identity_url) unless not_using_openid?
  rescue URI::InvalidURIError
    errors.add_to_base("Invalid OpenID URL")
  end
end
