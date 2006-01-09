require File.dirname(__FILE__) + '/../test_helper'

class TimeTest < Test::Unit::TestCase
  def test_should_show_year_delta
    assert_equal [Time.local(2006, 1, 1), Time.local(2007,1,1)], Time.local(2006,7,1).to_delta(:year)
  end

  def test_should_show_month_delta
    assert_equal [Time.local(2006, 7, 1), Time.local(2006,8,1)], Time.local(2006,7,15).to_delta(:month)
  end

  def test_should_show_daily_delta
    assert_equal [Time.local(2006, 7, 15), Time.local(2006,7,16)], Time.local(2006,7,15).to_delta
  end
end
