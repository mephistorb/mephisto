require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SafeERBTest < Test::Unit::TestCase
  def test_non_checking
    src = ERB.new("<%= File.open('#{__FILE__}'){|f| f.read} %>", nil, '-').src
    eval(src)
  end
  
  def test_checking
    ERB.with_checking_tainted do
      src = ERB.new("<%= File.open('#{__FILE__}'){|f| f.read} %>", nil, '-').src
      assert_raise(RuntimeError) { eval(src) }
    end
  end
  
  def test_checking_non_tainted
    src = ERB.new("<%= 'This string is not tainted' %>", nil, '-').src
    eval(src)
  end

  def use_template file
    path = File.join(File.dirname(__FILE__), file)
    @template = ActionView::Template.new(path)
    @view = ActionView::Base.new
  end

  def test_should_protect_html_templates
    use_template 'safe_erb_template.html.erb'
    assert_raise ActionView::TemplateError do
      @template.render_template(@view, :var => 'foo'.taint)
    end
  end

  def test_should_not_protect_text_plain_templates
    # This makes some ActionMailer templates work out of the box.
    use_template 'safe_erb_template.text.plain.erb'
    assert_equal "foo\n", @template.render_template(@view, :var => 'foo')
  end
end
