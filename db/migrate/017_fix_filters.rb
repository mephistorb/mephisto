class FixFilters < ActiveRecord::Migration
  def self.up
    Site.find(:all).each    { |s| s.update_attributes :filters => []                unless s.filters.to_s =~ /_filter/ }
    User.find(:all).each    { |u| u.update_attributes :filters => [:textile_filter] unless u.filters.to_s =~ /_filter/ }
    Article.find(:all).each { |a| a.update_attributes :filters => [:textile_filter] unless a.filters.to_s =~ /_filter/ }
  end

  def self.down
  end
end
