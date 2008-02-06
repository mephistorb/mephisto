ENV['RAILS_ENV'] = 'test'
RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../../')

require 'rubygems'
require 'active_support'
require 'test/unit' 

require File.join(File.dirname(__FILE__), '..', 'init.rb')

module Chocolate
  include_into 'Cookie', 'Coffee', :taste => :chocolate
  def taste_with_chocolate; "#{self.class.name} with chocolate!" end
end

module Latte
  include_into 'Coffee', 'Chai'
end

class Cookie
  def taste; "just a #{self.class.name}" end
end

class Coffee
  def taste; "just a #{self.class.name}" end
end

class Chai
end

class IncludeIntoTest < Test::Unit::TestCase
  def test_module_should_be_included_to_given_classes
    assert Cookie.included_modules.include?(Chocolate)
    assert Coffee.included_modules.include?(Chocolate)
  end
  
  def test_methods_should_be_alias_chained_in_given_classes
    assert_equal 'Cookie with chocolate!', Cookie.new.taste
    assert_equal 'Coffee with chocolate!', Coffee.new.taste
  end
  
  def test_should_work_without_alias_option
    assert Coffee.included_modules.include?(Latte)
    assert Chai.included_modules.include?(Latte)
  end
end