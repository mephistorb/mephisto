class User < UserAuth
  serialize   :filters, Array
  has_many :articles
  acts_as_paranoid

  def filters=(value)
    write_attribute :filters, [value, 'macro_filter'].flatten.collect { |v| v.blank? ? nil : v.to_sym }.compact.uniq
  end

  def to_liquid
    [:login, :email].inject({}) { |hsh, attr_name| hsh.merge attr_name.to_s => send(attr_name) }
  end
end
