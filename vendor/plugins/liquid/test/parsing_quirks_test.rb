#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'

class ParsingQuirksTest < Test::Unit::TestCase
  include Liquid

  def test_error_with_css
    text = %| div { font-weight: bold; } |
    template = Template.parse(text)
                                                    
    assert_equal text, template.render
    assert_equal [String], template.root.nodelist.collect {|i| i.class}
  end
end