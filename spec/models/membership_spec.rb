require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do

  before :each do
    # Take away the admin bits from any existing users in our database so
    # that they won't show up as server-wide admins on sites where they
    # don't even have a membership.
    User.update_all(['admin = ?', false])

    # Tell the site controller to leave on-disk theme directories alone.
    Site.any_instance.stubs(:setup_site_theme_directories).returns(nil)
    Site.any_instance.stubs(:flush_cache_and_remove_site_directories).returns(nil)

    @default_site = Site.make(:title => "Default Site")
    @cupcake_site = Site.make(:title => "Cupcake Site")

    @default_user = User.make(:login => 'default_user', :admin => true)
    @non_admin    = User.make(:login => 'non_admin',    :admin => false)
    @deleted_user = User.make(:login => 'deleted_user', :admin => false)

    # TODO - We're using destroy here to set deleted_at.  This is
    # apparently part of a rather iffy system for allowing users to
    # be disabled and renabled via acts_as_paranoid's invisible
    # hiding of deleted users.  As Rick suggests, we should rip this
    # out and replace it with named scopes.
    @deleted_user.destroy

    Membership.make(:site => @default_site, :user => @default_user,
                    :admin => true)
    Membership.make(:site => @cupcake_site, :user => @default_user,
                    :admin => false)
    Membership.make(:site => @default_site, :user => @non_admin,
                    :admin => false)
    Membership.make(:site => @default_site, :user => @deleted_user,
                    :admin => false)
  end
  
  it "finds user sites" do
    @default_user.sites.sort_by { |s| s.title }.should ==
      [@cupcake_site, @default_site]
  end
  
  it "finds site members" do
    @default_site.members.sort_by { |u| u.login }.should ==
      [@default_user, @non_admin]
    User.find_all_by_site(@default_site).sort_by { |u| u.login }.should ==
      [@default_user, @non_admin]
  end

  it "finds site admins" do
    @default_site.admins.should == [@default_user]
  end
  
  it "considers global admins to be site admins" do
    @cupcake_site.admins.should == [@default_user]
  end

  it "finds all users with deleted" do
    @default_site.users_with_deleted.sort_by { |u| u.login }.should ==
      [@default_user, @deleted_user, @non_admin]
    User.find_all_by_site_with_deleted(@default_site).sort_by { |u| u.login }.should ==
      [@default_user, @deleted_user, @non_admin]
  end
end
