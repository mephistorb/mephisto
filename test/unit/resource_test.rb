require File.dirname(__FILE__) + '/../test_helper'

context "Existing Theme Resources" do
  fixtures :sites

  def setup
    prepare_theme_fixtures
  end

  specify "should count correct assets" do
    assert_equal 3, sites(:first).resources.size
    assert_equal 0, sites(:hostess).resources.size
  end

  specify "should carry theme reference" do
    assert_equal sites(:first).theme.path, sites(:first).resources.theme.path
  end

  specify "should add resource" do
    f = sites(:hostess).resources.write 'foo.css'
    assert_equal (sites(:hostess).attachment_path + 'stylesheets/foo.css'), f
    assert !f.file?
  end

  specify "should add and create resource" do
    f = sites(:hostess).resources.write 'foo.css', 'foo'
    assert_equal (sites(:hostess).attachment_path + 'stylesheets/foo.css'), f
    assert_equal 'foo', f.read
    assert f.file?
  end
end

context "Resource" do
  def setup
    @resources = Resources.new
    @resources.stubs(:theme).returns(stub(:path => ''))
  end

  specify "should return correct content type for Pathname" do
    exts  = %w(.js .css .png .jpg .jpeg .gif .swf)
    types = %w(text/javascript text/css image/png image/jpeg image/jpeg image/gif application/x-shockwave-flash)
    exts.each_with_index do |ext, i|
      assert_equal types[i], @resources.content_type(Pathname.new("foo#{ext}"))
    end
  end
  
  specify "should return correct full path for filename" do
    paths = Hash.new { 'images' }
    paths['.js']  = 'javascripts'
    paths['.css'] = 'stylesheets'
    %w(.js .css .png .jpg .jpeg .gif .swf).each do |ext|
      assert_equal "#{paths[ext]}/foo#{ext}", @resources["foo#{ext}"]
    end
  end
end