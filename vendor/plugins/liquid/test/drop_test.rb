class ProductDrop < Liquid::Drop

  class TextDrop < Liquid::Drop
    def array
      ['text1', 'text2']
    end

    def text
      'text1'
    end
  end

  class CatchallDrop < Liquid::Drop
    def before_method(method)
      return 'method: ' << method
    end
  end

  def top_sales
    raise StandardError, 'worked'
  end
  
  def texts
    TextDrop.new
  end

  def catchall
    CatchallDrop.new
  end
end


#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper'

class DropsTest < Test::Unit::TestCase
  include Liquid
  
  def test_product_drop
    
    assert_nothing_raised do
      tpl = Liquid::Template.parse( '  '  )
      tpl.render('product' => ProductDrop.new)
    end
    assert_raise(StandardError) do
      tpl = Liquid::Template.parse( ' {{ product.top_sales }} '  )
      tpl.render('product' => ProductDrop.new)
    end
  end
  
  def test_text_drop
    output = Liquid::Template.parse( ' {{ product.texts.text }} '  ).render('product' => ProductDrop.new)
    assert_equal ' text1 ', output

  end

  def test_text_drop
    output = Liquid::Template.parse( ' {{ product.catchall.unknown }} '  ).render('product' => ProductDrop.new)
    assert_equal ' method: unknown ', output

  end

  def test_text_array_drop
    output = Liquid::Template.parse( '{% for text in product.texts.array %} {{text}} {% endfor %}'  ).render('product' => ProductDrop.new)
    assert_equal ' text1  text2 ', output
  end
  
  
end