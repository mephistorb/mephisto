$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'breakpoint'

Test::Unit::TestCase.class_eval do
  def assert_filters_called_on(klass, *filters)
    klass.called_filters = []
    yield
    assert_equal filters.length, (klass.called_filters & filters).length, "#{filters.join(', ')} expected, #{klass.called_filters.join(', ')} called"
  end

  def assert_no_filters_called_on(klass, &block)
    assert_filters_called_on klass, &block
  end
end

class FilteredColumn::Filters::Macros::Sample
  def self.filter(attributes, inner_text = '', text = '')
    "foo: #{attributes[:foo]} - flip: #{attributes[:flip]} - text: #{inner_text}"
  end
end
FilteredColumn.default_macros << :sample

FilteredColumn.constant_filters << :macro_filter
class Article < ActiveRecord::Base
  @@called_filters = []
  cattr_accessor :called_filters
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :body,                        :string
  column :body_html,                   :string
  column :textile_body,                :string
  column :textile_body_html,           :string
  column :textile_and_macro_body,      :string
  column :textile_and_macro_body_html, :string
  column :no_textile_body,             :string
  column :no_textile_body_html,        :string
  column :filters,                     :text
  column :sample_macro_body,           :string
  column :sample_macro_body_html,      :string

  filtered_column :body
  filtered_column :textile_body,           :only   => :textile_filter
  filtered_column :textile_and_macro_body, :only   => [:textile_filter, :macro_filter]
  filtered_column :no_textile_body,        :except => :textile_filter
  filtered_column :sample_macro_body,      :except => :macro_filter

  class << self
    alias_method :old_filter_text, :filter_text

    def filter_text(filter_name, text_to_filter)
      (called_filters << filter_name).uniq!
      old_filter_text(filter_name, text_to_filter)
    end
  end
end