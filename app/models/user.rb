class User < UserAuth
  has_many :articles
  acts_as_paranoid

  def to_liquid
    [:login, :email].inject({}) { |hsh, attr_name| hsh.merge attr_name.to_s => send(attr_name) }
  end
end
