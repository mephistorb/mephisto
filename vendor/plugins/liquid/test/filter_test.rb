#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper'


module MoneyFilter
  def money(input)
    sprintf(' %d$ ', input)
  end
  
  def money_with_underscore(input)
    sprintf(' %d$ ', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    sprintf(' %d$ CAD ', input)
  end
end


class FiltersTest < Test::Unit::TestCase
  include Liquid
  
  def setup
    @context = Context.new
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
  end
    
  def test_local_filter    
    assert_equal ' 1000$ ', Variable.new("var | money").render(@context)
  end  
  
  def test_underscore_in_filter_name
    assert_equal ' 1000$ ', Variable.new("var | money_with_underscore").render(@context)
  end

  def test_global_filter                                                             
    assert_equal 4, Variable.new("var | size").render(@context)
  end
  
  def test_second_filter_overwrites_first    
    @context.add_filters(CanadianMoneyFilter)  
    assert_equal ' 1000$ CAD ', Variable.new("var | money").render(@context)    
  end

end

class FiltersInTemplate < Test::Unit::TestCase
  include Liquid


  def test_local_global
    Template.register_filter(MoneyFilter)
    
    assert_equal " 1000$ ", Template.parse("{{1000 | money}}").render(nil, nil)
    assert_equal " 1000$ CAD ", Template.parse("{{1000 | money}}").render(nil, CanadianMoneyFilter)
  end
  
end