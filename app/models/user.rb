require 'digest/md5'
class User < UserAuth
  serialize   :filters, Array
  has_many :articles
  acts_as_paranoid

  def filters=(value)
    write_attribute :filters, [value].flatten.collect { |v| v.blank? ? nil : v.to_sym }.compact.uniq
  end

  def to_param
    login
  end

  def to_liquid
    [:login, :email].inject({}) { |hsh, attr_name| hsh.merge attr_name.to_s => send(attr_name) }
  end

  # FIXME
  def gravatar_url(size = 80)
    "http://www.gravatar.com/avatar.php?size=#{size}&amp;gravatar_id=#{Digest::MD5.hexdigest(email)}&amp;default=http://localhost:3002/images/avatar.gif"
  end
end
