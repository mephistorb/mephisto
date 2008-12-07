require File.dirname(__FILE__) + '/../test_helper'

context "Core Filters" do
  include CoreFilters

  def setup
    @context = {}
  end
  
  it "should assign variable" do
    assert_nil @context['foo']
    assign_to 'blah', 'foo'
    assert_equal 'blah', @context['foo']
  end

  it "should parse date into time" do
    assert_equal Time.local(2006, 1, 1), parse_date(Date.new(2006, 1))
  end

  it "should parse time into time" do
    assert_equal Time.utc(2006, 1, 1), parse_date(Time.utc(2006, 1))
  end

  it "should parse string into time" do
    assert_equal Time.utc(2006, 1, 1), parse_date('2006-1')
  end

  it "should parse nil into time" do
    assert_equal Time.now.utc.midnight, parse_date(nil).midnight
  end

  it "should parse empty string into time" do
    assert_equal Time.now.utc.midnight, parse_date('').midnight
  end
end