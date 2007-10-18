$: << File.join(File.dirname(__FILE__), '../lib')
require 'test/unit'
require 'expiring_attr_reader'
Class.send :include, ExpiringAttrReader

class Sample
  def self.calls
    @@calls
  end

  def self.reset
    @@calls = 0
  end

  expiring_attr_reader :foo, :expensive_method
  expiring_attr_reader :extra, %(expensive_method + ' and more!')
  expiring_attr_reader :foo!,  %(expensive_method + ' with bang')
  expiring_attr_reader :foo?,  %(expensive_method + ' with q')
  
  def expensive_method
    if @repeat
      raise "This shouldn't be called again"
    end
    @repeat  = true
    @@calls += 1
    'result'
  end
end

class ExpiringAttrReaderTest < Test::Unit::TestCase
  def setup
    Sample.reset
  end
  
  def test_adding_cached_reader
    assert_equal 'result and more!', Sample.new.extra
    assert_equal 1, Sample.calls
  end
  
  def test_should_not_repeat_expensive_method
    s1 = Sample.new
    s2 = Sample.new
    
    2.times { assert_equal 'result', s1.foo }
    assert_equal 1, Sample.calls
  
    2.times { assert_equal 'result', s2.foo }
    assert_equal 2, Sample.calls
  end
  
  def test_should_allow_expiring_attrs_with_bang_or_question
    s1 = Sample.new
    s2 = Sample.new
    
    2.times { assert_equal 'result with bang', s1.foo! }
    assert_equal 1, Sample.calls
    
    2.times { assert_equal 'result with q',    s2.foo? }
    assert_equal 2, Sample.calls
  end
end