require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  it "should delete memberships on destruction" do
    @site = Site.make
    @membership = Membership.make(:site => @site)
    @site.memberships.should == [@membership]
    lambda { @site.destroy }.should change(Membership, :count).by(-1)
  end  

  it "should have a timezone_name field" do
    @site = Site.make
    @site.timezone_name = "America/Montreal"
    assert_equal "America/Montreal", @site.timezone_name
    assert_equal TZInfo::Timezone.new("America/Montreal"), @site.timezone
  end
end

