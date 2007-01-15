require File.dirname(__FILE__) + '/../test_helper'
context "Drop Filters" do
  fixtures :sites, :sections, :contents, :assigned_sections, :assigned_assets, :assets
  include DropFilters, CoreFilters

  def setup
    @site    = sites(:first).to_liquid
    @context = mock_context 'site' => @site, 'section' => sections(:about).to_liquid
  end

  specify "should find section by path" do
    assert_equal sections(:home),  section('').source
    assert_equal sections(:about), section('about').source
    assert_equal sections(:bucharest), section('earth/europe/romania/bucharest').source
  end

  specify "should not find inexistent section by path even if children exist" do
    assert_nil section('earth/europe/romania')
  end

  specify "should find latest articles by section" do
    section = liquify(sections(:home)).first
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section, 2).collect(&:source)
    assert_equal contents(:welcome), latest_article(section).source
  end

  specify "should find latest comments by section" do
    section = liquify(sections(:home)).first
    assert_models_equal [contents(:welcome_comment)], latest_comments(section).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(section, 1).collect(&:source)
  end

  specify "should find latest articles by site" do
    assert_models_equal [contents(:welcome), contents(:about), contents(:site_map), contents(:another), contents(:at_beginning_of_next_month), contents(:at_end_of_month), contents(:at_middle_of_month), contents(:at_beginning_of_month)], 
      latest_articles(@site).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:about)], latest_articles(@site, 2).collect(&:source)
  end
  
  specify "should find latest comments by site" do
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site, 1).collect(&:source)
  end

  specify "should find child sections" do
    assert_models_equal [sections(:about), sections(:earth), sections(:links)], child_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa)], child_sections('earth').collect(&:source)
  end

  specify "should find descendant sections" do
    assert_models_equal sites(:first).sections.reject(&:home?), descendant_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa), sections(:bucharest)], descendant_sections('earth').collect(&:source)
  end

  specify "should find articles by month" do
    assert_models_equal sections(:home).articles.find_all_in_month(Time.now.year, Time.now.month), monthly_articles(liquify(sections(:home)).first).collect(&:source)
  end

  specify "should find article assets" do
    article = contents(:welcome).to_liquid(:mode => :single)
    article.context = @context
    assert_equal assets(:mp3), find_asset(article, 'podcast').source
  end

  specify "should find movies" do
    assert_models_equal [assets(:swf), assets(:mov)], assets_by_type('movie').collect(&:source)
  end

  specify "should find audio" do
    assert_models_equal [assets(:mp3)], assets_by_type('audio').collect(&:source)
  end

  specify "should find images" do
    assert_models_equal [assets(:png), assets(:gif)], assets_by_type('image').collect(&:source)
  end

  specify "should find others" do
    assert_models_equal [assets(:word), assets(:pdf)], assets_by_type('other').collect(&:source)
  end

  specify "should find assets by tag" do
    assert_models_equal [contents(:welcome)], tagged_articles("rails").collect(&:source)
  end

  specify "should find assets by tag" do
    assert_models_equal [assets(:gif)], tagged_assets("ruby").collect(&:source)
  end
end
