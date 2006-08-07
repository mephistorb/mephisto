require File.join(File.dirname(__FILE__), 'abstract_unit')

class FilteredColumnTest < Test::Unit::TestCase
  {
    :textile  => { :input  => '*foo*',        :output => '<p><strong>foo</strong></p>' },
    :markdown => { :input  => "# bar\n\nfoo", :output => "<h1>bar</h1>\n\n<p>foo</p>" },
    :macro    => { :input  => '<macro:sample foo="bar" flip="flop">hello world</macro:sample>', 
                   :output => "foo: bar - flip: flop - text: hello world" }
  }.each do |filter_name, values|
    define_method "test_should_filter_with_#{filter_name}" do
      assert_equal values[:output], Article.filter_text("#{filter_name}_filter", values[:input])
    end

    define_method "test_should_filter_model_attribute_with_#{filter_name}" do
      assert_filters_called_on Article, "#{filter_name}_filter".to_sym do
        a = Article.new :body => values[:input], :filters => "#{filter_name}_filter"
        a.save 
        assert_equal values[:output], a.body_html
      end
    end
  end
  
  def test_should_use_default_filter_names
    assert_equal 'Textile',  FilteredColumn::Filters::TextileFilter.filter_name
    assert_equal 'Markdown', FilteredColumn::Filters::MarkdownFilter.filter_name
    assert_equal 'Macro',    FilteredColumn::Filters::MacroFilter.filter_name
  end

  def test_should_allow_filter_name_customization
    assert_equal 'Markdown with Smarty Pants', FilteredColumn::Filters::SmartypantsFilter.filter_name
  end

  def test_should_use_default_filter_keys
    assert_equal :textile_filter,     FilteredColumn::Filters::TextileFilter.filter_key
    assert_equal :markdown_filter,    FilteredColumn::Filters::MarkdownFilter.filter_key
    assert_equal :macro_filter,       FilteredColumn::Filters::MacroFilter.filter_key
    assert_equal :smartypants_filter, FilteredColumn::Filters::SmartypantsFilter.filter_key
  end

  def test_should_not_bomb_on_nil_filters
    a = Article.new :filters => nil
    assert_equal [], a.filters
  end

  def test_should_call_no_filters_with_no_data
    assert_no_filters_called_on(Article) { Article.new }
  end

  def test_should_call_all_default_filters
    assert_filters_called_on Article, *FilteredColumn.default_filters do
      Article.new(:body => 'foo')
    end
  end

  def test_should_call_only_textile
    assert_filters_called_on Article, :textile_filter, :macro_filter do
      Article.new(:textile_body => 'foo')
    end
  end

  def test_should_override_standard_filters
    assert_filters_called_on Article, :textile_filter, :macro_filter do
      Article.new(:textile_body => 'foo', :filters => [:textile_filter, :macro_filter])
    end
  end

  def test_should_call_only_textile_and_markdown
    assert_filters_called_on Article, :textile_filter, :markdown_filter, :macro_filter do
      Article.new(:textile_and_macro_body => 'foo')
    end
  end

  def test_should_not_call_textile
    assert_filters_called_on Article, *(FilteredColumn.default_filters - [:textile_filter]) do
      Article.new(:no_textile_body => 'foo')
    end
  end

  def test_should_find_default_filters
    assert_equal [:macro_filter, :markdown_filter, :smartypants_filter, :textile_filter], FilteredColumn.default_filters
  end

  def test_should_find_default_macros
    assert_equal [:code, :flickr, :sample], FilteredColumn.default_macros
  end
end
