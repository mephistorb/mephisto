require File.dirname(__FILE__) + '/../test_helper'
class DropFiltersTest < ActiveSupport::TestCase
  fixtures :sites, :sections, :contents, :assigned_sections, :assigned_assets, :assets
  include DropFilters, CoreFilters

  def setup
    @site    = sites(:first).to_liquid
    @context = mock_context 'site' => @site, 'section' => sections(:about).to_liquid
  end

  test "should find section by path" do
    assert_equal sections(:home),  section('').source
    assert_equal sections(:about), section('about').source
    assert_equal sections(:bucharest), section('earth/europe/romania/bucharest').source
  end

  test "should not find inexistent section by path even if children exist" do
    assert_nil section('earth/europe/romania')
  end

  test "should find latest articles by section" do
    section = liquify(sections(:home)).first
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section, 2).collect(&:source)
    assert_equal contents(:welcome), latest_article(section).source
  end

  test "should find latest comments by section" do
    section = liquify(sections(:home)).first
    assert_models_equal [contents(:welcome_comment)], latest_comments(section).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(section, 1).collect(&:source)
  end

  test "should find latest articles by site" do
    assert_models_equal [contents(:welcome), contents(:about), contents(:site_map), contents(:another), contents(:at_beginning_of_next_month), contents(:article_1_only_in_page_section), contents(:article_2_only_in_page_section), contents(:at_end_of_month), contents(:at_middle_of_month), contents(:at_beginning_of_month)], 
      latest_articles(@site).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:about)], latest_articles(@site, 2).collect(&:source)
  end
  
  test "should find latest comments by site" do
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site, 1).collect(&:source)
  end

  test "should find child sections" do
    assert_models_equal [sections(:about), sections(:earth), sections(:links), sections(:paged_section)], child_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa)], child_sections('earth').collect(&:source)
  end

  test "should find descendant sections" do
    assert_models_equal sites(:first).sections.reject(&:home?), descendant_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa), sections(:bucharest)], descendant_sections('earth').collect(&:source)
  end

  test "should find articles by month" do
    assert_models_equal sections(:home).articles.find_all_in_month(Time.now.year, Time.now.month), monthly_articles(liquify(sections(:home)).first).collect(&:source)
  end

  test "should find article assets" do
    article = contents(:welcome).to_liquid(:mode => :single)
    article.context = @context
    assert_equal assets(:mp3), find_asset(article, 'podcast').source
  end

  def test_find_next
    another = contents(:another).to_liquid
    another.context = @context
    cupcake_welcome = contents(:cupcake_welcome).to_liquid
    cupcake_welcome.context = @context

    assert_equal next_article(another), contents(:welcome).to_liquid
    assert_equal next_article(another, sections(:home).to_liquid), contents(:welcome).to_liquid
    assert_equal next_article(cupcake_welcome, sections(:cupcake_home).to_liquid), nil
  end

  def test_should_find_previous
    another = contents(:another).to_liquid
    another.context = @context
    welcome = contents(:welcome).to_liquid
    welcome.context = @context

    assert_equal previous_article(another), nil
    assert_equal previous_article(another, sections(:home).to_liquid), nil
    assert_equal previous_article(welcome, sections(:home).to_liquid), another
    assert_not_equal previous_article(another, sections(:cupcake_home).to_liquid), contents(:at_beginning_of_next_month).to_liquid
  end

  test "should find movies" do
    assert_models_equal [assets(:swf), assets(:mov)], assets_by_type('movie').collect(&:source)
  end

  test "should find audio" do
    assert_models_equal [assets(:mp3)], assets_by_type('audio').collect(&:source)
  end

  test "should find images" do
    assert_models_equal [assets(:png), assets(:gif)], assets_by_type('image').collect(&:source)
  end

  test "should find others" do
    assert_models_equal [assets(:word), assets(:pdf)], assets_by_type('other').collect(&:source)
  end

  test "should find articles by tag" do
    assert_models_equal [contents(:future), contents(:another)], tagged_articles("rails").collect(&:source)
  end

  test "should find assets by tag" do
    assert_models_equal [assets(:gif)], tagged_assets("ruby").collect(&:source)
  end
end
