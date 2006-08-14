$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'breakpoint'

Test::Unit::TestCase.class_eval do
  def assert_filters_called_on(*filters)
    FilteredColumn::Processor.called_filters = []
    filtered = yield
    filtered.save if filtered
    assert_equal filters.length, (FilteredColumn::Processor.called_filters & filters).length, "#{filters.join(', ')} expected, #{FilteredColumn::Processor.called_filters.join(', ')} called"
  end

  def assert_no_filters_called_on(klass, &block)
    assert_filters_called_on &block
  end
end

class SampleMacro < FilteredColumn::Macros::Base
  def self.filter(attributes, inner_text = '')
    "foo: #{attributes[:foo]} - flip: #{attributes[:flip]} - text: #{inner_text}"
  end
end

FilteredColumn.macros[:sample_macro] = SampleMacro

class << FilteredColumn::Processor
  @@called_filters = []
  cattr_accessor :called_filters
  def filter_text_with_audit(filter_name, text_to_filter)
    (called_filters << filter_name).uniq!
    filter_text_without_audit(filter_name, text_to_filter)
  end
  alias_method_chain :filter_text, :audit
end

class Article < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :body,                           :string
  column :body_html,                      :string
  column :textile_body,                   :string
  column :textile_body_html,              :string
  column :textile_and_markdown_body,      :string
  column :textile_and_markdown_body_html, :string
  column :no_textile_body,                :string
  column :no_textile_body_html,           :string
  column :filters,                        :text
  column :sample_macro_body,              :string
  column :sample_macro_body_html,         :string

  filtered_column :body
  filtered_column :textile_body,              :only   => :textile_filter
  filtered_column :textile_and_markdown_body, :only   => [:textile_filter, :markdown_filter]
  filtered_column :no_textile_body,           :except => :textile_filter
  
  def save
    valid? && send(:callback, :before_save) && true
  end
end