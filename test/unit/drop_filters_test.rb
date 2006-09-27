require File.dirname(__FILE__) + '/../test_helper'
context "Drop Filters" do
  fixtures :sites, :sections, :contents, :assigned_sections
  include DropFilters

  def setup
    @site    = sites(:first).to_liquid
    @context = {'site' => @site, 'section' => sections(:about).to_liquid}
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
    section = sections(:home).to_liquid
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section, 2).collect(&:source)
    assert_equal contents(:welcome), latest_article(section).source
  end

  specify "should find latest comments by section" do
    section = sections(:home).to_liquid
    assert_models_equal [contents(:welcome_comment)], latest_comments(section).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(section, 1).collect(&:source)
  end

  specify "should find latest articles by site" do
    assert_models_equal [contents(:welcome), contents(:about), contents(:site_map), contents(:another)], latest_articles(@site).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:about)], latest_articles(@site, 2).collect(&:source)
  end
  
  specify "should find latest comments by site" do
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site).collect(&:source)
    assert_models_equal [contents(:welcome_comment)], latest_comments(@site, 1).collect(&:source)
  end

  specify "should find child sections" do
    assert_models_equal [sections(:about), sections(:earth)], child_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa)], child_sections('earth').collect(&:source)
  end

  specify "should find descendant sections" do
    assert_models_equal sites(:first).sections.reject(&:home?), descendant_sections('').collect(&:source)
    assert_models_equal [sections(:europe), sections(:africa), sections(:bucharest)], descendant_sections('earth').collect(&:source)
  end

end
