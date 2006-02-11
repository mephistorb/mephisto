#require 'filters/abstract_filter'
#require 'filtered_column'

#Dir["#{directory}/lib/filters/*_filter.rb"].each do |filter|
#  filter_name = File.basename(filter).sub(/\.rb/, '')
#  require filter
#  FilteredColumn::filters[filter_name.sub(/_filter/, '').to_sym] = filter_name.camelize.constantize
#end

ActiveRecord::Base.send(:include, FilteredColumn)
