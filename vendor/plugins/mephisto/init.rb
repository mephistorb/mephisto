# monkey patches galore!

Object::RAILS_PATH = Pathname.new(File.expand_path(RAILS_ROOT))

Inflector.inflections do |inflect|
  #inflect.plural /^(ox)$/i, '\1en'
  #inflect.singular /^(ox)en/i, '\1'
  #inflect.irregular 'person', 'people'
  inflect.uncountable %w( audio )
end

# Time.now.to_ordinalized_s :long
# => "February 28th, 2006 21:10"
module ActiveSupport::CoreExtensions::Time::Conversions
  def to_ordinalized_s(format = :default)
    format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[format] 
    return to_default_s if format.nil?
    strftime(format.gsub(/%d/, '_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
  end
end

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

Module.class_eval do
  # Creates an expiring method that is called once, and overwrites itself so future calls are faster.  It does this
  # by setting an instance variable and an attr_reader on the singleton class.  Other instances of this object are
  # not affected.
  #
  # (example taken from http://redhanded.hobix.com/inspect/methodsThatSelfDestruct.html)
  #   class Hit
  #     expiring_attr_reader :country, %(`geoiplookup #{@ip}`.chomp.gsub(/^GeoIP Country Edition: /,""))
  #
  #     def initialize(ip)
  #       @ip = ip
  #     end
  #   end
  #
  # A better idea would be to refactor the expensive code into a method:
  #
  #   class Hit
  #     expiring_attr_reader :country, "self.class.geoiplookup @ip"
  #
  #     def initialize(ip)
  #       @ip = ip
  #     end
  #
  #     def self.geoiplookup(ip)
  #       `geoiplookup #{ip}`.chomp.gsub(/^GeoIP Country Edition: /,"")
  #     end
  #   end
  def expiring_attr_reader(method_name, value)
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{method_name}
        class << self; attr_reader :#{method_name}; end
        @#{method_name} = eval(%(#{value}))
      end
    EOS
  end

  # A hash that maps Class names to an array of Modules to mix in when the class is instantiated.
  @@class_mixins = {}
  mattr_reader :class_mixins

  # Specifies that this module should be included into the given classes when they are instantiated.
  #
  #   module FooMethods
  #     include_into "Foo", "Bar"
  #   end
  def include_into(*klasses)
    klasses.flatten!
    klasses.each do |klass|
      (@@class_mixins[klass] ||= []) << self
      @@class_mixins[klass].uniq!
    end
  end
end

Class.class_eval do
  # Instantiates a class and adds in any class_mixins that have been registered for it.
  def inherited_with_mixins(klass)
    returning inherited_without_mixins(klass) do |value|
      mixins = @@class_mixins[klass.name]
      klass.send(:include, *mixins) if mixins
    end
  end
  
  alias_method_chain :inherited, :mixins
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

Liquid::For.send :include, Mephisto::Liquid::ForWithSorting