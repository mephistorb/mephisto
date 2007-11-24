require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
  describe FixtureHash do
    before :all do
      @definition = ModelStubbing.definitions[:default]
      @users      = @definition.models[:users]
      @user       = @users.default
      @user.stub!(:connection).and_return(FakeConnection.new)
      @fixture    = FixtureHash.new(@user).update :foo => 1, :bar => :baz
    end
    
    it "creates key list" do
      keys = @fixture.key_list
      keys.index("`foo`").should_not be_nil
      keys.index("`bar`").should_not be_nil
    end
    
    it "creates value list" do
      values = @fixture.value_list
      values.index(%("1")).should_not be_nil
      values.index(%("baz")).should_not be_nil
    end
  end
end