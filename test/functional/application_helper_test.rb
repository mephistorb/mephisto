require File.dirname(__FILE__) + '/../test_helper'
require 'application_helper'

class ApplicationHelperTest < Test::Unit::TestCase
  include ApplicationHelper
  
  def test_should_return_default_avatar_for_nil_users
    assert_equal 'avatar.gif', gravatar_url_for(nil)
  end
end
