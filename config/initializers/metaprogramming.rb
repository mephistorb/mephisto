# need to make pathname safe for windows!
Pathname.class_eval do
  def read(*args)
    returning [] do |s|
      File.open(@path, 'rb') { |f| s << f.read }
    end.to_s
  end
end

Symbol.class_eval do
  def to_liquid
    to_s
  end
end

# http://rails.techno-weenie.net/tip/2005/12/23/make_fixtures
ActiveRecord::Base.class_eval do
  # person.dom_id #-> "person-5"
  # new_person.dom_id #-> "person-new"
  # new_person.dom_id(:bare) #-> "new"
  # person.dom_id(:person_name) #-> "person-name-5"
  def dom_id(prefix=nil)
    display_id = new_record? ? "new" : id
    prefix ||= self.class.name.underscore
    prefix != :bare ? "#{prefix.to_s.dasherize}-#{display_id}" : display_id
  end

  # Write a fixture file for testing
  def self.to_fixture(fixture_path = nil)
    File.open(File.expand_path(fixture_path || "test/fixtures/#{table_name}.yml", RAILS_ROOT), 'w') do |out|
      YAML.dump find(:all).inject({}) { |hsh, record| hsh.merge(record.id => record.attributes) }, out
    end
  end

  expiring_attr_reader :referenced_cache_key, '"[#{[id, self.class.name] * ":"}]"'
end

class Object
  def tap
    yield self; self;
  end
end