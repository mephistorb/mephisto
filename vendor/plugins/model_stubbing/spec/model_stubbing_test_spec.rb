require File.join(File.dirname(__FILE__), 'models')
require 'test/spec'
require 'mocha'

Test::Unit::TestCase.extend ModelStubbing

describe "Sample" do
  define_models do
    time 2007, 6, 1
  
    model User do
      stub :name => 'fred', :admin => false
      stub :admin, :admin => true
    end
  
    model Post do
      stub :title => 'first', :user => all_stubs(:admin_user), :published_at => current_time + 5.days
    end
  end
  
  def test_should_retrieve_stubs
    assert_equal 'fred', users(:default).name
    assert_equal false,  users(:default).admin
    
    assert_equal 'fred', users(:admin).name
    assert users(:admin).admin
  end
  
  def test_should_retrieve_instantiated_stubs
    assert_equal users(:default).id, users(:default).id
  end
  
  def test_should_generate_custom_stubs
    custom = users(:default, :admin => true)
    assert_not_equal users(:default).id, custom.id
    assert_not_equal custom.id, users(:default, :admin => true).id
  end
  
  def test_should_associate_stubs
    assert_equal users(:admin), posts(:default).user
  end
  
  def test_should_stub_current_time
    assert_equal Time.utc(2007, 6, 1), current_time
    assert_equal Time.utc(2007, 6, 6), posts(:default).published_at
  end
end