# temporarily load this before all other plugins
::Object::RAILS_PATH = Pathname.new(File.expand_path(RAILS_ROOT))

Module.class_eval do
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
      (@@class_mixins[klass] ||= []) << name.to_s
      @@class_mixins[klass].uniq!
    end
  end
  
  # add any class mixins that have been registered for this class
  def auto_include!
    mixins = @@class_mixins[name]
    send(:include, *mixins.collect { |name| name.constantize }) if mixins
  end
end

Class.class_eval do
  # Instantiates a class and adds in any class_mixins that have been registered for it.
  def inherited_with_mixins(klass)
    returning inherited_without_mixins(klass) do |value|
      klass.auto_include!
    end
  end
  
  alias_method_chain :inherited, :mixins
end