require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_helper'

class Admin::ArticlesHelperTest < Test::Unit::TestCase
  include Admin::ArticlesHelper
  
  def test_should_show_published_at_dates
    assert_equal 'not published', published_at_for(nil)
    assert_equal 'not published', published_at_for(Article.new)
  end
end
