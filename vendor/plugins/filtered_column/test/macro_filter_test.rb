require File.join(File.dirname(__FILE__), 'abstract_unit')

class MacroFilterTest < Test::Unit::TestCase
  
  def test_macros_should_include
    ["code", "flickr"].each do |key|
      assert FilteredColumn::Filters::MacroFilter.send(:macros).has_key? "code"
    end
  end
  
  def test_code_macro_with_language
    html = filter_text '<macro:code lang="ruby">assert_equal 4, 2 + 2</macro:code>'
    
    expected = "<table class=\"CodeRay\"><tr>\n  <td class=\"line_numbers\" title=\"click to toggle\" onclick=\"with (this.firstChild.style) { display = (display == '') ? 'none' : '' }\"><pre><tt>\n</tt></pre></td>\n  <td class=\"code\"><pre ondblclick=\"with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }\">assert_equal <span class=\"i\">4</span>, <span class=\"i\">2</span> + <span class=\"i\">2</span></pre></td>\n</tr></table>\n"
    
    assert_equal expected, html
  end
  
  def test_code_macro_without_language
    html = filter_text '<macro:code>assert_equal 4, 2 + 2</macro:code>'
    expected = '<pre><code>assert_equal 4, 2 + 2</code></pre>'
    assert_equal expected, html
  end
  
  def test_flickr_macro
    html = filter_text '<macro:flickr img="31367273" size="small"/>'
    expected = "<div style=\"\" class=\"flickrplugin\"><a href=\"http://flickr.com/photos/Scott Laird/31367273\"><img src=\"http://static.flickr.com/21/31367273_38de39d915_m.jpg\" width=\"240\" height=\"160\" alt=\"Phil presenting DHH with _How to win friends and influence people_\" title=\"Phil presenting DHH with _How to win friends and influence people_\"/></a></div>"
    assert_equal expected, html
  end  
  
  private
  
  def filter_text(text)
    FilteredColumn::Filters::MacroFilter.filter(text)
  end
end