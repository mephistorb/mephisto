module Mephisto
  module Liquid
    module ForWithSorting
      def self.included(base)
        base.alias_method_chain :render, :sorting
      end

      def render_with_sorting(context)
        context.registers[:for] ||= Hash.new(0)
        
        collection = context[@collection_name]
        collection = collection.to_a if collection.is_a?(Range)
        
        return '' if collection.nil? or collection.empty?
        
        context[@collection_name] = collection.sort_by { |i| i[@attributes['sort_by']] } if @attributes['sort_by']
        
        render_without_sorting(context)
      end
    end
  end
end