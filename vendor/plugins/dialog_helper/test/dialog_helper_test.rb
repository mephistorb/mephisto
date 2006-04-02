$:.unshift(File.dirname(__FILE__) + '/../lib')

require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'rubygems'
require 'breakpoint'

require 'action_controller/test_process'

ActionController::Base.logger = nil
ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

class DialogHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include Technoweenie::DialogHelper

  def setup
    @controller = Class.new do
      def url_for(options, *parameters_for_method_reference)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end.new
  end

  def test_should_create_correct_dialog_options
    assert_equal %({foo:'bar', onCallback:function() {}, ontest:'test'}),
      send(:options_for_dialog, :foo => 'bar', :on_callback => 'function() {}', :ontest => 'test')
  end

  def test_should_create_dialog_class
    assert_equal %(new Dialog.Confirm({});), create_dialog(:confirm)
    assert_equal %(new Dialog.FooBar({});), create_dialog(:foo_bar)
  end

  def test_should_create_dialog_with_options
    assert_equal %(new Dialog.Confirm({message:'Are you sure?', okayTest:'Sure!', onOkay:function() { alert('whoa'); }});), 
      create_dialog(:confirm, :message => 'Are you sure?', :okay_test => 'Sure!', :on_okay => "function() { alert('whoa'); }")
  end

  def test_should_create_link_to_dialog
    assert_dom_equal %(<a href="#" onclick="new Dialog.Confirm({message:'Are you sure?', okayTest:'Sure!', onOkay:function() { alert('whoa'); }});; return false;">Open</a>), 
      link_to_dialog('Open', :confirm, :message => 'Are you sure?', :okay_test => 'Sure!', :on_okay => "function() { alert('whoa'); }")
  end
end