require File.dirname(__FILE__) + '/test_helper'

class ContextTest < Test::Unit::TestCase
  include Liquid

  def setup
    @context = Liquid::Context.new
  end

  def test_variables
    @context['test'] = 'test'
    assert_equal 'test', @context['test']
  end

  def test_variables_not_existing
    assert_equal nil, @context['test']
  end
  
  def test_scoping
    assert_nothing_raised do
      @context.push
      @context.pop
    end
    
    assert_raise(Liquid::ContextError) do
      @context.pop
    end
  end
  
  def test_length_query
    
    @context['numbers'] = [1,2,3,4]
    
    assert_equal 4, @context['numbers.size']
    
  end
  
  def test_add_filter
    
    filter = Module.new do 
      def hi(output)
        output + ' hi!'
      end
    end
    
    context = Context.new 
    context.add_filters(filter)
    assert_equal 'hi? hi!', context.invoke(:hi, 'hi?')
    
    context = Context.new 
    assert_equal 'hi?', context.invoke(:hi, 'hi?')

    context.add_filters(filter)
    assert_equal 'hi? hi!', context.invoke(:hi, 'hi?')
        
  end
  
  def test_override_global_filter
    global = Module.new do 
      def notice(output)
        "Global #{output}"
      end
    end
    
    local = Module.new do 
      def notice(output)
        "Local #{output}"
      end
    end
        
    Template.register_filter(global)    
    assert_equal 'Global test', Template.parse("{{'test' | notice }}").render
    assert_equal 'Local test', Template.parse("{{'test' | notice }}").render({}, [local])
  end
    
  def test_only_intended_filters_make_it_there

    filter = Module.new do 
      def hi(output)
        output + ' hi!'
      end
    end

    context = Context.new 
    methods = context.strainer.methods
    context.add_filters(filter)
    assert_equal (methods + ['hi']).sort, context.strainer.methods.sort
end
  
  def test_add_item_in_outer_scope
    @context['test'] = 'test'
    @context.push
    assert_equal 'test', @context['test']
    @context.pop    
    assert_equal 'test', @context['test']    
  end

  def test_add_item_in_inner_scope
    @context.push
    @context['test'] = 'test'
    assert_equal 'test', @context['test']
    @context.pop    
    assert_equal nil, @context['test']    
  end
  
  def test_hierachical_data
    @context['hash'] = {"name" => 'tobi'}
    assert_equal 'tobi', @context['hash.name']
  end
  
  def test_keywords
    assert_equal true, @context['true']
    assert_equal false, @context['false']
  end

  def test_digits
    assert_equal 100, @context['100']
    assert_equal 100.00, @context['100.00']
  end
  
  def test_strings
    assert_equal "hello!", @context['"hello!"']
    assert_equal "hello!", @context["'hello!'"]
  end  
  
  def test_merge
    @context.merge({ "test" => "test" })
    assert_equal 'test', @context['test']
    @context.merge({ "test" => "newvalue", "foo" => "bar" })
    assert_equal 'newvalue', @context['test']
    assert_equal 'bar', @context['foo']    
  end
end