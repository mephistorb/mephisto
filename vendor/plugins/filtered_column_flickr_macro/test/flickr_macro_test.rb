require File.join(File.dirname(__FILE__), 'abstract_unit')

class MacroFilterTest < Test::Unit::TestCase
  def test_should_retrieve_macro
    assert_equal FlickrMacro, FilteredColumn.macros[:flickr_macro]
  end
  
  def test_flickr_macro
    html = process_macros %(<macro:flickr img="31367273" size="small"/>)
    expected = "<div style=\"\" class=\"flickrplugin\"><a href=\"http://flickr.com/photos/Scott Laird/31367273\"><img src=\"http://static.flickr.com/21/31367273_38de39d915_m.jpg\" width=\"240\" height=\"160\" alt=\"Phil presenting DHH with _How to win friends and influence people_\" title=\"Phil presenting DHH with _How to win friends and influence people_\"/></a></div>"
    assert_equal expected, html
  end  
  
  private
    def process_macros(text)
      FilteredColumn::Processor.process_macros(text)
    end
end