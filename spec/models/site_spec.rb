require File.dirname(__FILE__) + '/../spec_helper'
describe Site do
  define_models do
    
    model Site do
      stub :destroy, :host => 'destroy.com'
    end
    
    model User do
      stub :destroy, :login => 'destroy'
    end
    
    model Membership do
      stub :destroy, :site => all_stubs(:destroy_site), :user => all_stubs(:destroy_user)
    end
  end

  it "should delete memberships on destruction" do
    sites(:destroy).memberships.should == [memberships(:destroy)] 
    lambda { sites(:destroy).destroy }.should change(Membership, :count).by(-1)
  end
  
end
