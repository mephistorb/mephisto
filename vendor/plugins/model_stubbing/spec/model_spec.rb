require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Model do
  before :all do
    @model = ModelStubbing.definitions[:default].models[:users]
  end
  
  it "is defined in stub file" do
    @model.should be_kind_of(Model)
  end

  it "retrieves stubs" do
    @model.retrieve_record(:default).should == @model.default.record
    @model.retrieve_record(:admin).should   == @model.stubs[:admin].record
  end
end

describe Model, "initialization with default options" do
  before :all do
    pending "Can't use default options without ActiveSupport" unless Object.const_defined?(:ActiveSupport)
    @default = Model.new(nil, Post)
  end
  
  it "sets Model#name" do
    @default.name.should == :posts
  end
  
  it "sets class" do
    @default.model_class.should == Post
  end
  
  it "sets plural value" do
    @default.plural.should == :posts
  end
  
  it "sets singular value" do
    @default.singular.should == 'post'
  end
end

describe Model, "initialization with custom options" do
  before :all do
    @custom  = Model.new(nil, Post, :name => :customs, :plural => :many_customs, :singular => :one_custom)
  end
  
  it "sets Model#name" do
    @custom.name.should == :customs
  end
  
  it "sets class" do
    @custom.model_class.should == Post
  end
  
  it "sets plural value" do
    @custom.plural.should == :many_customs
  end
  
  it "sets singular value" do
    @custom.singular.should == :one_custom
  end
end

describe Model, "duping itself" do
  before :all do
    @model = ModelStubbing.definitions[:default].models[:users]
    @copy  = @model.dup
  end
  
  it "references same definition" do
    @model.definition.should == @copy.definition
  end
  
  %w(model_class name plural singular).each do |attr|
    it "keeps @#{attr} intact" do
      @model.send(attr).should == @copy.send(attr)
    end
  end
  
  it "has the same number of stubs" do
    @model.stubs.size.should == @copy.stubs.size
  end

  it "has equal stubs" do
    @model.stubs.each do |key, stub|
      @model.stubs[key].should == @copy.stubs[key]
      @model.stubs[key].model.should == @copy.stubs[key].model
    end
  end

  it "has equal stubs with duped models" do
    @model.stubs.each do |key, stub|
      @model.stubs[key].model.should_not be_equal(@copy.stubs[key].model)
    end
  end

  it "has duped stubs" do
    @model.stubs.each do |key, stub|
      @model.stubs[key].should_not be_equal(@copy.stubs[key])
    end
  end
  
  it "is not the same instance" do
    @model.object_id.should_not == @copy.object_id
  end
  
  it "is still be equal" do
    @model.should == @copy
  end
end