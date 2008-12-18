require File.dirname(__FILE__) + '/../spec_helper'

# Verify that our safe_erb patches are working.
describe "An ERB template" do
  before :each do
    @template = ERB.new('<%= var %>')
  end

  it "should not raise an error when untained values are interpolated" do
    var = "foo"
    assert_equal var, @template.result(binding)
  end

  it "should raise an error when tained values are interpolated" do
    assert_raise RuntimeError do
      var = "foo".taint
      @template.result(binding)
    end
  end
end
