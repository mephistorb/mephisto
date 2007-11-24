require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Stub do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @users      = @definition.models[:users]
    @posts      = @definition.models[:posts]
    @user       = @users.default
    @post       = @posts.default
  end

  it "is defined in stub file" do
    @user.should be_kind_of(Stub)
  end
  
  it "has the default stub's attributes" do
    @user.attributes.should == {:name => 'bob', :admin => false}
    @post.attributes.should == {:title => 'initial', :user => @users.stubs[:admin], :published_at => @definition.current_time + 5.days}
  end
  
  it "#with returns merged attributes" do
    @post.with(:title => 'fred').should == {:title => 'fred', :user => @users.stubs[:admin].record, :published_at => @definition.current_time + 5.days}
  end
  
  it "#only returns only given keys" do
    @post.only(:title).should == {:title => 'initial'}
  end
  
  it "#except returns other keys" do
    @post.except(:published_at).should == {:title => 'initial', :user => @users.stubs[:admin].record}
  end
  
  it "merges named stub attributes with default attributes" do
    @users.stubs[:admin].attributes.should == {:name => 'bob', :admin => true}
  end
  
  it "sets default model stubs in the definition's global stubs" do
    @definition.stubs[:user].should == @user
  end
  
  it "sets custom model stubs in the defintion's global stub with stub name prefix" do
    @definition.stubs[:admin_user].should == @users.stubs[:admin]
  end
end

describe Stub, "duping itself" do
  before :all do
    @stub = ModelStubbing.definitions[:default].models[:users].default
    @copy = @stub.dup
  end 
  
  %w(name model attributes global_key).each do |attr|
    it "keeps @#{attr} intact" do
      @stub.send(attr).should == @copy.send(attr)
    end
  end
  
  it "is not the same instance" do
    @stub.object_id.should_not == @copy.object_id
  end
  
  it "is still be equal" do
    @stub.should == @copy
  end
end

describe Stub, "duping itself with duped model" do
  before :all do
    @stub = ModelStubbing.definitions[:default].models[:users].default
    @copy = @stub.dup @stub.model.dup
  end 
  
  %w(name model attributes global_key).each do |attr|
    it "keeps @#{attr} intact" do
      @stub.send(attr).should == @copy.send(attr)
    end
  end
  
  it "is not the same instance" do
    @stub.object_id.should_not == @copy.object_id
  end
  
  it "is still be equal" do
    @stub.should == @copy
  end
end

describe Stub, "duping itself with different model" do
  before :all do
    @defn = ModelStubbing.definitions[:default]
    @stub = @defn.models[:users].default
    @copy = @stub.dup @defn.models[:posts].dup
  end
  
  %w(name attributes).each do |attr|
    it "keeps @#{attr} intact" do
      @stub.send(attr).should == @copy.send(attr)
    end
  end
  
  it "creates global key from new model" do
    @copy.global_key.should == :post
  end
  
  it "is not the same instance" do
    @stub.object_id.should_not == @copy.object_id
  end
  
  it "is not equal" do
    @stub.should_not == @copy
  end
end

describe Stub, "instantiating a record" do
  before :all do
    @model   = ModelStubbing.definitions[:default].models[:users]
    @stub = @model.default
  end
  
  before do
    ModelStubbing.records.clear
  end
  
  it "sets id" do
    @stub.record.id.should >= 1000
  end
  
  it "is one of the model's model class" do
    @record  = @stub.record
    @record.should be_kind_of(@model.model_class)
  end
  
  it "sets correct attributes" do
    @record  = @stub.record
    @record.name.should  == 'bob'
    @record.admin.should == false
  end
  
  it "allows custom attributes during instantiation" do
    @record  = @stub.record :admin => true
    @record.admin.should == true
  end
  
  it "allows use of #current_time in a stub" do
    ModelStubbing.definitions[:default].models[:posts].default.record.published_at.should == Time.utc(2007, 6, 6)
  end
end

describe Stub, "instantiating a record with an association" do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @users      = @definition.models[:users]
    @posts      = @definition.models[:posts]
    @user       = @users.stubs[:admin]
    @post       = @posts.default
  end
  
  before do
    ModelStubbing.records.clear
  end
  
  it "stubs associated records" do
    @post.record.user.should == @user.record
  end
end