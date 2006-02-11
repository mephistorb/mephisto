require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  has_many :articles

  validates_uniqueness_of   :login, :email, :salt
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_presence_of     :login, :email
  validates_presence_of     :password, 
                            :password_confirmation,
                            :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  before_save :encrypt_password
  serialize   :filters, Array
  
  # Uncomment this to use activation
  # before_create :make_activation_code

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # use this instead if you want user activation
    # u = find :first, :select => 'id, salt', :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u = find_by_login(login) # need to get the salt
    return nil unless u
    find :first, :conditions => ["id = ? AND crypted_password = ?", u.id, u.encrypt(password)]
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Uncomment these methods for user activation  These also help let the mailer know precisely when the user is activated.
  # There's also a commented-out before hook above and a protected method below.
  #
  # The controller has a commented-out 'activate' action too.
  #
  # # Activates the user in the database.
  # def activate
  #   @activated = true
  #   update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  # end
  # 
  # # Returns true if the user has just been activated.
  # def recently_activated?
  #   @activated
  # end

  def filters=(value)
    write_attribute :filters, [value].flatten.collect(&:to_sym)
  end

  protected
  # before filter 
  def encrypt_password
    return unless password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.nil? or not password.blank?
  end

  public
  # If you're going to use activation, uncomment this too
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split('//').sort_by {rand}.join )
  end
end
