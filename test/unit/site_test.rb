require File.dirname(__FILE__) + '/../test_helper'

context "Site" do
  fixtures :sites, :contents

  specify "should create site without accepting comments" do
    site = Site.new :host => 'foo.com', :comment_age => -1
    assert_valid site
    assert !site.accept_comments?
    assert !site.approve_comments?
  end

  specify "should create site with approving comments" do
    site = Site.new :host => 'foo.com', :approve_comments => true
    assert_valid site
    assert site.accept_comments?
    assert site.approve_comments?
  end

  specify "should find valid articles" do
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  specify "should find by host" do
    assert_equal sites(:first), Site.find_by_host('test.com')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.com')
  end

  specify "should allow empty filter" do
    sites(:first).update_attribute :filter, ''
    assert_equal '', sites(:first).reload.filter
  end

  specify "should create site with default home section" do
    site = nil
    assert_difference Site, :count do
      assert_difference Section, :count do
        site = Site.create! :host => 'foo.com'
      end
    end
    assert_equal 'Home', site.sections.first.name
    assert_equal '',     site.sections.first.path
    assert_equal 1,      site.sections.size
    assert site.sections.first.home?
  end

  specify "should generate search url" do
    assert_equal '/search?q=abc',        sites(:first).search_url('abc')
    assert_equal '/search?q=abc&page=2', sites(:first).search_url('abc', 2)
  end
  
  specify "should generate tag url" do
    assert_equal '/tags',         sites(:first).tag_url
    assert_equal '/tags/foo',     sites(:first).tag_url('foo')
    assert_equal '/tags/foo/bar', sites(:first).tag_url('foo', 'bar')
  end
end

context "Site Membership" do
  fixtures :sites, :users, :memberships
  specify "should find member by token" do
    assert_equal users(:quentin), sites(:first).user_by_token(users(:quentin).token)
  end

  specify "should not find member by expired token" do
    assert_nil sites(:first).user_by_token(users(:arthur).token)
  end

  specify "should not find member by token in wrong site" do
    memberships(:quentin_first).destroy
    users(:quentin).update_attribute :admin, false
    assert_nil sites(:first).user_by_token(users(:quentin).token)
  end

  specify "should find member by email" do
    assert_equal users(:quentin), sites(:first).user_by_email(users(:quentin).email)
  end

  specify "should not find member by email in wrong site" do
    memberships(:arthur_first).destroy
    assert_nil sites(:first).user_by_email(users(:arthur).email)
  end
end

context "Default Site Options" do
  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  specify "should accept comments by default" do
    assert @site.accept_comments?
  end

  specify "should not approve comments by default" do
    assert !@site.approve_comments?
  end
  
  specify "should preset search path" do
    assert_equal 'search', @site.search_path
  end
  
  specify "should preset tag path" do
    assert_equal 'tags', @site.tag_path
  end
  
  specify "should set permalink" do
    assert_equal ':year/:month/:day/:permalink', @site.permalink_style
  end
end

context "Site Validations" do
  fixtures :sites

  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  specify "should validate unique host" do
    assert_valid sites(:first)
    assert_no_difference Site, :count do
      assert Site.create(:host => sites(:first).host.upcase, :title => 'Copy').new_record?
    end
  end

  specify "should require valid host name format" do
    s = Site.new
    ['foo', '-34.com', 'A!'].each do |host|
      s.host = host
      s.valid?
      assert s.errors.on(:host), "host valid with #{host}"
    end
  end
  
  specify "should require valid search path" do
    @site.search_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:search_path)
  end
  
  specify "should downcase search path" do
    @site.search_path = "SEARCHES"
    assert_valid @site
    assert_equal 'searches', @site.search_path
  end
  
  specify "should require valid tag path" do
    @site.tag_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:tag_path)
  end
  
  specify "should downcase tag path" do
    @site.tag_path = "TAGGING"
    assert_valid @site
    assert_equal 'tagging', @site.tag_path
  end
  
  specify "should downcase permalink style" do
    @site.permalink_style = 'ARTICLE/:ID'
    assert_valid @site
    assert_equal 'article/:id', @site.permalink_style
  end
end

context "Site Template" do
  fixtures :sites, :sections

  def setup
    prepare_theme_fixtures
  end

  specify "should raise error on missing template" do
    sites(:first).templates[:archive].unlink
    assert_raise Mephisto::MissingTemplateError do
      sites(:first).send(:parse_template, sites(:first).templates[:archive], {}, {})
    end
  end

  specify "should find preferred for site" do
    assert_site_template_name :home, :section
  end

  specify "should find fallback for site with preferred template" do
    FileUtils.rm File.join(THEME_ROOT, 'site-1', 'current', 'templates', 'home.liquid')
    assert_site_template_name :section, :section
  end

  specify "should find preferred for site layout" do
    FileUtils.cp File.join(THEME_ROOT, 'site-1', 'current', 'layouts', 'layout.liquid'), File.join(THEME_ROOT, 'site-1', 'current', 'layouts', 'custom_layout.liquid')
    sites(:first).sections.home.update_attribute :layout, 'custom_layout'
    assert_site_layout_name :custom_layout, :layout
  end

  specify "should find fallback for site with preferred layout" do
    sites(:first).sections.home.update_attribute :layout, 'custom_layout'
    assert_site_layout_name :layout
  end

  protected
    def assert_site_template_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site            = options[:site] || sites(:first)
      section         = options[:section] || site.sections.home
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_preferred_template, section, template_type))
    end
    def assert_site_layout_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site            = options[:site] || sites(:first)
      section         = options[:section] || site.sections.home
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_layout_template, section, template_type))
    end
end