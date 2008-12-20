require File.dirname(__FILE__) + '/../spec_helper'

# Verify that our readonly_record patches are working.
describe "Any record" do
  before :each do
    @article = Article.make(:title => "Original title")
  end

  it "should be writable by default" do
    assert !ActiveRecord::Base.all_records_are_readonly?
    @article.title = "Hello!"
    @article.save!
  end

  it "should not be writable inside with_readonly_records" do
    assert_raise ActiveRecord::ReadOnlyRecord do
      ActiveRecord::Base.with_readonly_records do
        assert ActiveRecord::Base.all_records_are_readonly?
        @article.title = "Hello!"
        @article.save!
      end
    end
  end

  it "should be writable inside with_writable_records" do
    ActiveRecord::Base.with_readonly_records do
      ActiveRecord::Base.with_writable_records do
        assert !ActiveRecord::Base.all_records_are_readonly?
        @article.title = "Hello!"
        @article.save!
      end
    end
  end
end

