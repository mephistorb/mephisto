require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  before :each do
    @site = Site.make
  end

  it "should delete memberships on destruction" do
    @membership = Membership.make(:site => @site)
    @site.memberships.should == [@membership]
    lambda { @site.destroy }.should change(Membership, :count).by(-1)
  end  

  it "should have a timezone_name field" do
    @site.timezone_name = "America/Montreal"
    assert_equal "America/Montreal", @site.timezone_name
    assert_equal TZInfo::Timezone.new("America/Montreal"), @site.timezone
  end

  it "should default to using Textile for comments" do
    Site.new.filter.should == "textile_filter"
  end
end
