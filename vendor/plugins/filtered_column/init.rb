ActiveRecord::Base.send(:include, FilteredColumn::Mixin)

Dir["#{directory}/lib/filtered_column/filters/*_filter.rb"].sort.each do |filter_name|
  (FilteredColumn.default_filters << File.basename(filter_name).sub(/\.rb/, '').to_sym).uniq!
end

Dir["#{directory}/lib/filtered_column/filters/macros/*_macro.rb"].sort.each do |macro_name|
  (FilteredColumn.default_macros << File.basename(macro_name).sub(/\.rb/, '').to_sym).uniq!
end
