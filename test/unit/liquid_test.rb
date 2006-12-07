require File.dirname(__FILE__) + '/../test_helper'

context "Liquid" do
  specify "should allow sorting in for block" do
    assert_template_result('123','{% for item in array sort_by: num %}{{item.num}}{% endfor %}',
      'array' => [ {'num' => 3}, {'num' => 1}, {'num' => 2} ])
  end
end