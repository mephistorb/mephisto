require File.dirname(__FILE__) + '/../test_helper'
context "Site" do
  fixtures :sites, :contents, :sections

  it "should create site without accepting comments" do
    site = Site.new :host => 'foo.com', :comment_age => -1
    assert_valid site
    assert !site.accept_comments?
    assert !site.approve_comments?
  end

  it "should create site with approving comments" do
    site = Site.new :host => 'foo.com', :approve_comments => true
    assert_valid site
    assert site.accept_comments?
    assert site.approve_comments?
  end

  it "should find valid articles" do
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  it "should find by host" do
    assert_equal sites(:first), Site.find_by_host('test.host')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.com')
  end

  it "should allow empty filter" do
    sites(:first).update_attribute :filter, ''
    assert_equal '', sites(:first).reload.filter
  end

  it "should create site with default home section" do
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

  it "should generate search url" do
    assert_equal '/search?q=abc',            sites(:first).search_url('abc')
    assert_equal '/search?q=abc&amp;page=2', sites(:first).search_url('abc', 2)
  end
  
  it "should generate tag url" do
    assert_equal '/tags',           sites(:first).tag_url
    assert_equal '/tags/foo',       sites(:first).tag_url('foo')
    assert_equal '/tags/foo/bar',   sites(:first).tag_url('foo', 'bar')
    assert_equal '/tags/foo%20bar', sites(:first).tag_url('foo bar')
  end

  it "should order sections in site" do
    assert_reorder_sections [sections(:home), sections(:about), sections(:earth), sections(:europe), sections(:africa), sections(:bucharest), sections(:links), sections(:paged_section)],
                            [sections(:home), sections(:earth), sections(:europe), sections(:africa), sections(:bucharest), sections(:links), sections(:about), sections(:paged_section)]
  end

  it "should find at least one extension (.liquid)" do
    assert !Site.extensions.empty?
    assert Site.extensions.include?(".liquid")
  end

  protected
    def assert_reorder_sections(old_order, expected)
      assert_models_equal old_order, sites(:first).sections
      sites(:first).sections.order! expected.collect(&:id)
      assert_models_equal expected, sites(:first).sections(true)
    end
end

context "Site Membership" do
  fixtures :sites, :users, :memberships

  it "should find member by token" do
    assert_equal users(:quentin), sites(:first).user_by_token(users(:quentin).token)
  end

  it "should not find member by expired token" do
    assert_nil sites(:first).user_by_token(users(:arthur).token)
  end

  it "should not find member by token in wrong site" do
    memberships(:quentin_first).destroy
    users(:quentin).update_attribute :admin, false
    assert_nil sites(:first).user_by_token(users(:quentin).token)
  end

  it "should find member by email" do
    assert_equal users(:quentin), sites(:first).user_by_email(users(:quentin).email)
  end

  it "should not find member by email in wrong site" do
    memberships(:arthur_first).destroy
    assert_nil sites(:first).user_by_email(users(:arthur).email)
  end
end

context "Default Site Options" do
  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  it "should accept comments by default" do
    assert @site.accept_comments?
  end

  it "should not approve comments by default" do
    assert !@site.approve_comments?
  end
  
  it "should preset search path" do
    assert_equal 'search', @site.search_path
  end
  
  it "should preset tag path" do
    assert_equal 'tags', @site.tag_path
  end
  
  it "should set permalink" do
    assert_equal ':year/:month/:day/:permalink', @site.permalink_style
  end
end

context "Site Validations" do
  fixtures :sites

  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  it "should validate unique host" do
    assert_valid sites(:first)
    assert_no_difference Site, :count do
      assert Site.create(:host => sites(:first).host.upcase, :title => 'Copy').new_record?
    end
  end

  it "should require valid host name format" do
    s = Site.new
    ['foo', '-34.com', 'A!'].each do |host|
      s.host = host
      s.valid?
      assert s.errors.on(:host), "host valid with #{host}"
    end
  end
  
  it "should require valid search path" do
    @site.search_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:search_path)
  end
  
  it "should downcase search path" do
    @site.search_path = "SEARCHES"
    assert_valid @site
    assert_equal 'searches', @site.search_path
  end
  
  it "should require valid tag path" do
    @site.tag_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:tag_path)
  end
  
  it "should downcase tag path" do
    @site.tag_path = "TAGGING"
    assert_valid @site
    assert_equal 'tagging', @site.tag_path
  end
  
  it "should downcase permalink style" do
    @site.permalink_style = 'ARTICLE/:ID'
    assert_valid @site
    assert_equal 'article/:id', @site.permalink_style
  end
end
