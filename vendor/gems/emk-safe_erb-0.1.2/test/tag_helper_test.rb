require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::ActiveRecordHelper

  def test_inclusion_in_taghelper
    assert self.respond_to?(:escape_once_with_untaint)
    assert self.respond_to?(:escape_once_without_untaint)
  end

  def test_taghelper_untaints
    evil_str = "evil knievel".taint
    assert !escape_once(evil_str).tainted?
    assert escape_once_without_untaint(evil_str).tainted?
  end

  Post = Struct.new(:published_at)
  def post
    @post ||= Post.new(Time.now.taint)
  end

  def test_datetime_select_should_untaint
    assert !datetime_select(:post, :published_at).tainted?
  end

  # TODO - Add tests for error_messages_for helper.  This is a little
  # tricky, because we'll need an ActiveRecord::Base instance.
end
