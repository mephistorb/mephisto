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
        
        if @attributes['sort_by']
          sorted_name = "sorted_#{@collection_name.tr '.', '_'}"
          context[sorted_name] = collection.sort_by { |i| i[@attributes['sort_by']] }
          @collection_name = sorted_name
        end
        
        render_without_sorting(context)
      end
    end
  end
end