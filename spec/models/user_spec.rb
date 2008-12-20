require File.dirname(__FILE__) + '/../spec_helper'
 
describe User do
  before :each do
    @site = Site.make
  end

  def make_admin_with_token token
    user = User.make(:token_expires_at => 1.day.from_now, :admin => true)
    user.token = token # May be nil, so we can't pass to User.make.
    user.save!
  end

  it "should not find users with nil token" do
    # This test always passed, before we did anything specific to fix it.
    make_admin_with_token nil
    User.find_by_token(@site, nil).should be_nil
  end

  it "should not find users with empty token" do
    make_admin_with_token ''
    User.find_by_token(@site, '').should be_nil
  end

  def make_admin_with_login_and_password login, password
    User.make(:login => login, :password => password, :admin => true)
  end

  it "should not find users with empty login" do
    begin
      make_admin_with_login_and_password '', 'foo'
      User.authenticate_for(@site, '', 'foo').should be_nil
    rescue ActiveRecord::RecordInvalid # This is OK, too.
    end
  end

  it "should not find users with empty password" do
    begin
      make_admin_with_login_and_password 'joe', ''
      User.authenticate_for(@site, 'joe', '').should be_nil
    rescue ActiveRecord::RecordInvalid # This is OK, too.
    end
  end
end

