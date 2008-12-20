require File.dirname(__FILE__) + '/../spec_helper'

# Verify that our safe_erb patches are working.
describe ActionView::Template do
  before :each do
    path = File.join(File.dirname(__FILE__), 'safe_erb_template.html.erb')
    @template = ActionView::Template.new(path)
    @view = ActionView::Base.new
  end

  it "should not raise an error when untained values are interpolated" do
    assert_equal "foo\n", @template.render_template(@view, :var => 'foo')
  end

  it "should fail when tainted values are interpolated into HTML" do
    assert_raise ActionView::TemplateError do
      @template.render_template(@view, :var => 'foo'.taint)
    end
  end
end
