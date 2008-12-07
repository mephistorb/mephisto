require File.dirname(__FILE__) + '/../test_helper'

class SectionDropTest < Test::Unit::TestCase
  fixtures :sites, :sections, :contents, :assigned_sections

  def test_equality
    section = sections(:home).to_liquid
    assert_equal section, sections(:home)
    assert_equal section, sections(:home).to_liquid
  end

  def test_should_convert_section_to_drop
    assert_kind_of Liquid::Drop, sections(:home).to_liquid
  end
  
  def test_should_show_current_status
    assert  sections(:home).to_liquid(true).current
    assert !sections(:home).to_liquid.current
  end

  def test_should_expose_section_fields
    [:id, :name, :path].each do |attr|
      assert_equal sections(:home).send(attr), sections(:home).to_liquid.before_method(attr)
    end

    assert_equal sections(:home).send(:read_attribute, :articles_count), sections(:home).to_liquid.before_method(:articles_count)
  end
  
  def test_should_report_section_types
    assert sections(:home).to_liquid['is_blog']
    [:about, :cupcake_home, :cupcake_about].each { |s| assert sections(s).to_liquid['is_paged'] }
  end
  
  def test_should_get_earliest_article_published_date
    assert_equal contents(:another).published_at.beginning_of_month.to_date, sections(:home).to_liquid['earliest_month']
  end
  
  def test_should_get_month_array
    this_month = Time.now.utc.beginning_of_month.to_date
    months = sections(:home).articles.collect { |a| (a.published? && ( a.published_at.beginning_of_month.to_date <= this_month)) ? a.published_at.beginning_of_month.to_date.to_s(:db) : nil }.compact.uniq.sort.reverse
    assert_equal months, sections(:home).to_liquid['months'].collect { |d| d.to_s(:db) }
  end
end

class SectionContentsTest < ActiveSupport::TestCase
  fixtures :sites, :sections, :contents, :assigned_sections

  def setup
    @section = sections(:home).to_liquid
    @section.context = mock_context
  end

  test "should list articles" do
    assert_models_equal [contents(:welcome), contents(:another)], @section.articles.collect(&:source)
    assert_models_equal [contents(:welcome)], @section.latest_articles(1).collect(&:source)
  end

  test "should list comments" do
    assert_models_equal [contents(:welcome_comment)], @section.comments.collect(&:source)
    assert_models_equal [contents(:welcome_comment)], @section.latest_comments(1).collect(&:source)
  end
end
