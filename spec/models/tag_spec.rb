require File.dirname(__FILE__) + '/../spec_helper'

ModelStubbing.define_models :tags, :copy => false do
  model Tag do
    [:ruby, :rails, :mongrel, :plugin].each do |t|
      stub t, :name => t.to_s
    end
  end
end

describe Tag, "#parse" do
  define_models :tags

  it "parses comma separated tags" do
    Tag.parse('a,b,c').should  == %w(a b c)
    Tag.parse('a, b c').should == %w(a b\ c)
  end

  it "parses simple tags" do
    Tag.parse('"a" "b" "c"').should == %w(a b c)
  end

  it "parses space delimited tags" do
    Tag.parse('a b c').should == %w(a b c)
  end

  it "parses tags with double quotes" do
    Tag.parse('tagging, it"s, weirdness').should == %w(tagging it"s weirdness)
  end
  
  it "parses tags with single quotes" do
    Tag.parse('"tagging" "it\'s" "weirdness"').should == %w(tagging it's weirdness)
  end
  
  it "parses tags with quotes and spaces" do
    Tag.parse('"tagging" "it\'s weirdness"').should == %w(tagging it's\ weirdness)
  end
  
  it "returns tag array" do
    Tag.parse(%w(a b c)).should == %w(a b c)
  end
  
  it "returns unique tags" do
    ["a, b, b", %("a" "b" " b ")].each do |input|
      Tag.parse(input).should == %w(a b)
    end
  end
end

describe Tag do
  define_models :tags

  it "finds or creates tags" do
    lambda { Tag.find_or_create %w(ruby rails foo) }.should change { Tag.count }.by(1)
  end
  
  it "creates tags from comma separated list" do
    lambda { Tag.parse_to_tags 'ruby, a, b, rails, c' }.should change { Tag.count }.by(3)
  end
  
  it "equals tags of the same name" do
    tags(:ruby).should == 'ruby'
    tags(:ruby).should == Tag.new(:name => "ruby")
  end
  
  it "selects tags by name" do
    Tag[:ruby].should == tags(:ruby)
  end
end
