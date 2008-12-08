require File.join(File.dirname(__FILE__), 'abstract_unit')

class CodeMacroTest < Test::Unit::TestCase

  def test_should_retrieve_macro
    assert_equal CodeMacro, FilteredColumn.macros[:code_macro]
  end

  def test_code_macro_with_language
    html = process_macros '<macro:code lang="ruby">assert_equal 4, 2 + 2</macro:code>'
    
    expected = "<table class=\"CodeRay\"><tr>\n  <td class=\"line_numbers\" title=\"click to toggle\" onclick=\"with (this.firstChild.style) { display = (display == '') ? 'none' : '' }\"><pre><tt>\n</tt></pre></td>\n  <td class=\"code\"><pre ondblclick=\"with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }\">assert_equal <span class=\"i\">4</span>, <span class=\"i\">2</span> + <span class=\"i\">2</span></pre></td>\n</tr></table>\n"
    
    assert_equal expected, html
  end

  def test_code_macro_with_language_and_line_numbers
    html = process_macros '<macro:code lang="ruby" line_numbers="list">assert_equal 4, 2 + 2</macro:code>'
    
    expected = "<ol class=\"CodeRay\">\n<li>assert_equal <span class=\"i\">4</span>, <span class=\"i\">2</span> + <span class=\"i\">2</span></li>\n</ol>\n"
    
    assert_equal expected, html
  end

  def test_code_macro_with_invalid_line_numbers
    html = process_macros '<macro:code line_numbers="whatever" lang="ruby">assert_equal 4, 2 + 2</macro:code>'
    expected = "<table class=\"CodeRay\"><tr>\n  <td class=\"line_numbers\" title=\"click to toggle\" onclick=\"with (this.firstChild.style) { display = (display == '') ? 'none' : '' }\"><pre><tt>\n</tt></pre></td>\n  <td class=\"code\"><pre ondblclick=\"with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }\">assert_equal <span class=\"i\">4</span>, <span class=\"i\">2</span> + <span class=\"i\">2</span></pre></td>\n</tr></table>\n"
    assert_equal expected, html
  end

  def test_code_macro_without_language
    html = process_macros '<macro:code>assert_equal 4, 2 + 2</macro:code>'
    expected = '<pre><code>assert_equal 4, 2 + 2</code></pre>'
    assert_equal expected, html
  end

  def test_code_macro_with_invalid_line_numbers_and_language
    html = process_macros '<macro:code line_numbers="whatever">assert_equal 4, 2 + 2</macro:code>'
    expected = '<pre><code>assert_equal 4, 2 + 2</code></pre>'
    assert_equal expected, html
  end

  def test_code_macro_with_embedded_html_chars
    html = process_macros '<macro:code lang="ruby">x < y</macro:code>'
    expected = "<table class=\"CodeRay\"><tr>\n  <td class=\"line_numbers\" title=\"click to toggle\" onclick=\"with (this.firstChild.style) { display = (display == '') ? 'none' : '' }\"><pre><tt>\n</tt></pre></td>\n  <td class=\"code\"><pre ondblclick=\"with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }\">x &lt; y</pre></td>\n</tr></table>\n"
    assert_equal expected, html
  end

  def test_code_macro_with_embedded_html_chars_and_no_lang
    html = process_macros '<macro:code>x < y</macro:code>'
    expected = "<pre><code>x &lt; y</code></pre>"
    assert_equal expected, html
  end
  
  private
    def process_macros(text)
      FilteredColumn::Processor.new(nil, text).filter
    end
end
