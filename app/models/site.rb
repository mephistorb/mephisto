class Site < ActiveRecord::Base
  serialize :filters, Array

  def filters=(value)
    write_attribute :filters, [value].flatten.collect(&:to_sym)
  end
end
