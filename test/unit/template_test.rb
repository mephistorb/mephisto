require File.dirname(__FILE__) + '/../test_helper'

class TemplateTest < Test::Unit::TestCase
  fixtures :attachments, :db_files

  def test_should_ignore_resources_and_assets
    assert_equal 10, Template.count
  end

  def test_should_select_correct_templates
    {:main    => [:home, :index],
     :single  => [:single, :index],
     :section => [:section, :archive, :index],
     :archive => [:archive, :index],
     :page    => [:page, :single, :index],
     :search  => [:search, :archive, :index],
     :author  => [:author,  :archive, :index],
     :error   => [:error, :index]}.each do |template_type, filenames|
       templates = Template.templates_for(template_type)
       (filenames << :layout).each do |filename|
         assert templates[filename.to_s], "#{filename} does not exist for #{template_type}"
       end
    end
  end


  def test_preferred_template_hierarchy_sanity
    assert_template_type :home,    :main
    assert_template_type :single,  :single
    assert_template_type :section, :section
    #assert_template_type :page,    :page
    #assert_template_type :author,  :author
    assert_template_type :search,  :search
    #assert_template_type :error,   :error
  end

  def test_fallback_templates
    [:home, :single, :section, :page, :author, :search, :error].each { |n| attachments(n).destroy }
    assert_template_type :index,   :main
    assert_template_type :index,   :single
    assert_template_type :archive, :section
    #assert_template_type :index,   :page
    #assert_template_type :archive, :author
    assert_template_type :archive, :search
    #assert_template_type :index,   :error

    attachments(:archive).destroy
    assert_template_type :index, :section
    assert_template_type :index, :search
    #assert_template_type :index, :author
  end

  protected
  def assert_template_type(expected_template_name, template_type)
    assert_equal(attachments(expected_template_name).data, Template.find_preferred(template_type))
  end
end
