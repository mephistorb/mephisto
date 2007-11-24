require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  define_models do
    model Site do
      stub :cupcake, :title => "Cupcake", :host => 'cupcake.com'
    end
    
    model User do
      stub :non_admin, :login => 'arthur', :admin => false
      stub :deleted,   :login => "aaron",  :admin => false, :deleted_at => current_time - 5.minutes
    end
    
    model Membership do
      stub :admin_on_default,   :site => all_stubs(:site),         :user => all_stubs(:user),           :admin => true
      stub :admin_on_cupcake,   :site => all_stubs(:cupcake_site), :user => all_stubs(:user),           :admin => true
      stub :user_on_default,    :site => all_stubs(:site),         :user => all_stubs(:non_admin_user), :admin => false
      stub :deleted_on_default, :site => all_stubs(:site),         :user => all_stubs(:deleted_user),   :admin => false
    end
  end
  
  it "finds user sites" do
    users(:default).sites.sort_by { |s| s.title }.should == [sites(:cupcake), sites(:default)]
  end
  
  it "finds site members" do
    sites(:default).members.sort_by { |u| u.login }.should == [users(:non_admin), users(:default)]
    User.find_all_by_site(sites(:default)).sort_by { |u| u.login }.should == [users(:non_admin), users(:default)]
  end

  it "finds site admins" do
    sites(:default).admins.should == [users(:default)]
  end
  
  it "finds all users with deleted" do
    sites(:default).users_with_deleted.sort_by { |u| u.login }.should == [users(:deleted), users(:non_admin), users(:default)]
    User.find_all_by_site_with_deleted(sites(:default)).sort_by { |u| u.login }.should == [users(:deleted), users(:non_admin), users(:default)]
  end
end