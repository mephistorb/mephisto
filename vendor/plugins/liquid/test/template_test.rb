require File.dirname(__FILE__) + '/test_helper'

class TemplateTest < Test::Unit::TestCase
  include Liquid
  
  def test_tokenize_strings
    assert_equal [' '], Template.tokenize(' ')
    assert_equal ['hello world'], Template.tokenize('hello world')
  end                         
  
  def test_tokenize_variables
    assert_equal ['{{funk}}'], Template.tokenize('{{funk}}')
    assert_equal [' ', '{{funk}}', ' '], Template.tokenize(' {{funk}} ')
    assert_equal [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], Template.tokenize(' {{funk}} {{so}} {{brother}} ')
    assert_equal [' ', '{{  funk  }}', ' '], Template.tokenize(' {{  funk  }} ')
  end                             
  
  def test_tokenize_blocks    
    assert_equal ['{%comment%}'], Template.tokenize('{%comment%}')
    assert_equal [' ', '{%comment%}', ' '], Template.tokenize(' {%comment%} ')
    
    assert_equal [' ', '{%comment%}', ' ', '{%endcomment%}', ' '], Template.tokenize(' {%comment%} {%endcomment%} ')
    assert_equal ['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], Template.tokenize("  {% comment %} {% endcomment %} ")
    
  end                                                          

end