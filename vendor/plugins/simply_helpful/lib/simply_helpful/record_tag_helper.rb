module SimplyHelpful
  module RecordTagHelper
    def div_for(record, *args, &block)
      prefix  = args.first.is_a?(Hash) ? nil : args.shift
      options = args.first.is_a?(Hash) ? args.shift : {}
      concat content_tag(:div, capture(&block), 
        options.merge({ :class => "#{dom_class(record)} #{options[:class]}".strip, :id => dom_id(record, prefix) })), 
        block.binding
    end
  end
end

module ActionView
  module Helpers
    module UrlHelper
      def link_to_with_record_identification(attr_name, record = {}, html_options = nil, *parameters_for_method_reference)
        case record
          when Hash, String, Symbol, NilClass
            link_to_without_record_identification(attr_name, record, html_options, *parameters_for_method_reference)
          else
            url = SimplyHelpful::RecordIdentifier.named_route(record, self)
            link_to_without_record_identification(record.send(attr_name), url, html_options, *parameters_for_method_reference)
        end
      end
      
      alias_method_chain :link_to, :record_identification
    end
  end
end