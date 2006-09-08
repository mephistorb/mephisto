require 'digest/sha1'
class UserAuth < ActiveRecord::Base
  set_table_name 'users'
  self.abstract_class = true
  @@membership_options = {:select => 'distinct users.*, memberships.admin as site_admin', :order => 'users.login',
    :joins => 'left outer join memberships on users.id = memberships.user_id'}

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitve => false
  before_save :encrypt_password
  
  # Uncomment this to use activation
  # before_create :make_activation_code

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate_for(site, login, password)
    u = find(:first, @@membership_options.merge(
      :conditions => ['users.login = ? and (memberships.site_id = ? or users.admin = ?)', login, site.id, true]))
    u && u.authenticated?(password) ? u : nil
  end

  def self.find_by_site(site, id)
    with_deleted_scope { find_by_site_with_deleted(site, id) }
  end

  def self.find_by_site_with_deleted(site, id)
    find_with_deleted(:first, @@membership_options.merge(
      :conditions => ['users.id = ? and (memberships.site_id = ? or users.admin = ?)', id, site.id, true]))
  end

  def self.find_all_by_site(site, options = {})
    with_deleted_scope { find_all_by_site_with_deleted(site, options) }
  end

  def self.find_all_by_site_with_deleted(site, options = {})
    find_with_deleted(:all, @@membership_options.merge(options.reverse_merge(:conditions => ['memberships.site_id = ? or users.admin = ?', site.id, true]))).uniq
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split('//').sort_by {rand}.join )
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.nil? || !password.blank?
    end
end
