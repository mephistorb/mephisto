$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'ruby-debug'
require 'model_stubbing'
begin
  require 'active_support'
rescue LoadError
  puts $!.to_s
end

class FakeTester
end

class FakeConnection
  def quote_column_name(name)
    "`#{name}`"
  end
  
  def quote(value, whatever)
    value.to_s.inspect
  end
end

class BlankModel
  attr_accessor :id
  attr_reader :attributes
  
  def initialize(attributes = {})
    @attributes = attributes
    attributes.each do |key, value|
      set_attribute key, value
    end
  end
  
  def []=(key, value)
    set_attribute key, value
  end
  
  def ==(other_model)
    self.class == other_model.class && id == other_model.id
  end
  
  def inspect
    "#{self.class.name} ##{id} => #{@attributes.inspect}"
  end

private
  def meta_class
    @meta_class ||= class << self; self end
  end

  def set_attribute(key, value)
    meta_class.send :attr_accessor, key
    send "#{key}=", value
  end
end

User = Class.new BlankModel do
  def self.table_name() @table_name ||= 'users' end
end
Post = Class.new BlankModel do
  def self.table_name() @table_name ||= 'posts' end
end
module Foo
  Bar = Class.new BlankModel do
    def self.table_name() @table_name ||= 'foo_bars' end
  end
end

ModelStubbing.define_models do
  time 2007, 6, 1
  
  model User do
    stub :name => 'bob', :admin => false
  end
  
  model Foo::Bar do
    stub :blah => 'foo'
  end
end

ModelStubbing.define_models do
  model User do
    stub :admin, :admin => true # inherits from default fixture
  end
  
  model Post do
    # uses admin user fixture above
    stub :title => 'initial', :user => all_stubs(:admin_user), :published_at => current_time + 5.days
  end
end

ModelStubbing.definitions[:default].setup_on FakeTester

Debugger.start