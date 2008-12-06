# TODO this seems to be deleting the site theme - please revisit
# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe Site do
#   it "should delete memberships on destruction" do
#     @site = Site.make
#     @membership = Membership.make(:site => @site)
#     @site.memberships.should == [@membership]
#     lambda { @site.destroy }.should change(Membership, :count).by(-1)
#   end  
# end
