require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags

  def test_should_parse_comma_separated_tags
    assert_equal %w(a b c), Tag.parse('a, b, c')
    assert_equal %w(a b\ c), Tag.parse('a, b c')
  end

  def test_should_parse_simple_tags
    assert_equal %w(a b c), Tag.parse("'a' 'b' 'c'")
    assert_equal %w(a b c), Tag.parse('"a" "b" "c"')
  end

  def test_should_parse_more_complicated_tags
    # with quotation marks _in_ the string.
    assert_equal %w(tagging it's weirdness), Tag.parse('tagging, it\'s, weirdness')
    assert_equal %w(tagging it"s weirdness), Tag.parse('tagging, it"s, weirdness')
    assert_equal %w(tagging it's weirdness), Tag.parse('"tagging" "it\'s" "weirdness"')
    assert_equal %w(tagging it's weirdness), Tag.parse("'tagging' 'it's' 'weirdness'")
    # with spaces...
    assert_equal %w(tagging it's\ weirdness), Tag.parse("'tagging' 'it's weirdness'")
    assert_equal %w(tagging it's\ weirdness), Tag.parse('"tagging" "it\'s weirdness"')
  end

  def test_should_return_tag_array
    assert_equal %w(a b c), Tag.parse(%w(a b c))
  end
  
  def test_should_return_unique_tags
    ["a, b, b", %('a' 'b' 'b'), %("a" "b" " b ")].each do |input|
      assert_equal %w(a b), Tag.parse(input), "Failed for: #{input.inspect}"
    end
  end

  def test_should_find_or_create_tags
    assert_difference Tag, :count do
      Tag.find_or_create %w(ruby rails foo)
    end
  end

  def test_should_create_tags_from_comma_separated_list
    assert_difference Tag, :count, 3 do
      Tag.parse_to_tags 'ruby, a, b, rails, c'
    end
  end

  def test_tag_equality
    assert_equal tags(:ruby), 'ruby'
    assert_equal Tag.find_by_name('ruby'), tags(:ruby)
  end

  def test_should_select_tags_by_name
    assert_equal tags(:ruby), Tag[:ruby]
  end
end
