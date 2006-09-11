class User < UserAuth
  @@admin_scope = {:find => { :conditions => ['admin = ?', true] } }
  has_many :articles
  acts_as_paranoid

  has_many :memberships, :dependent => :destroy
  has_many :sites, :through => :memberships, :order => 'title, host'

  def self.find_admins(*args)
    with_scope(@@admin_scope) { find *args }
  end

  def to_liquid
    [:login, :email].inject({}) { |hsh, attr_name| hsh.merge attr_name.to_s => send(attr_name) }
  end
end
