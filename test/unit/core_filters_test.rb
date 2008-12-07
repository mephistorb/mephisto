require File.dirname(__FILE__) + '/../test_helper'

class CoreFiltersTest < ActiveSupport::TestCase
  include CoreFilters

  def setup
    @context = {}
  end
  
  test "should assign variable" do
    assert_nil @context['foo']
    assign_to 'blah', 'foo'
    assert_equal 'blah', @context['foo']
  end

  test "should parse date into time" do
    assert_equal Time.local(2006, 1, 1), parse_date(Date.new(2006, 1))
  end

  test "should parse time into time" do
    assert_equal Time.utc(2006, 1, 1), parse_date(Time.utc(2006, 1))
  end

  test "should parse string into time" do
    assert_equal Time.utc(2006, 1, 1), parse_date('2006-1')
  end

  test "should parse nil into time" do
    assert_equal Time.now.utc.midnight, parse_date(nil).midnight
  end

  test "should parse empty string into time" do
    assert_equal Time.now.utc.midnight, parse_date('').midnight
  end
end