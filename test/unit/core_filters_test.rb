require File.dirname(__FILE__) + '/../test_helper'

context "Core Filters" do
  include CoreFilters

  def setup
    @context = {}
  end
  
  specify "should assign variable" do
    assert_nil @context['foo']
    assign_to 'blah', 'foo'
    assert_equal 'blah', @context['foo']
  end
end