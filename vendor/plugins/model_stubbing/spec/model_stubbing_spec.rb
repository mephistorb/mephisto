require File.join(File.dirname(__FILE__), 'spec_helper')

# support rspec 1.0.8 and edge
(Spec::DSL.const_defined?(:ExampleGroup) ? Spec::DSL::ExampleGroup : Spec::DSL::Example).extend ModelStubbing

describe "Sample Stub Usage" do
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
  
  it "should retrieve stubs" do
    users(:default).name.should == 'fred'
    users(:default).admin.should == false
    
    users(:admin).name.should == 'fred'
    users(:admin).admin.should == true
  end
  
  it "should retrieve instantiated stubs" do
    users(:default).id.should == users(:default).id
  end
  
  it "should generate custom stubs" do
    custom = users(:default, :admin => true)
    custom.id.should_not == users(:default).id
    users(:default, :admin => true).id.should_not == custom.id
  end
  
  it "should associate stubs" do
    posts(:default).user.should == users(:admin)
  end
  
  it "should stub current time" do
    current_time.should == Time.utc(2007, 6, 1)
    posts(:default).published_at.should == Time.utc(2007, 6, 6)
  end
end