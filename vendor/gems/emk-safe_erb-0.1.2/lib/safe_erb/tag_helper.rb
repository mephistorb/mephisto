module ActionView
  module Helpers
    module TagHelper
      def escape_once_with_untaint(html)
        escape_once_without_untaint(html).untaint
      end
      
      alias_method_chain :escape_once, :untaint
    end

    module DateHelper
      # TODO - This is almost certainly too aggressive, and it will need to
      # be fine-tuned.
      def datetime_select_with_untaint(*args)
        datetime_select_without_untaint(*args).untaint
      end
      alias_method_chain :datetime_select, :untaint
    end

    module ActiveRecordHelper
      # TODO - This is almost certainly too aggressive, and it will need to
      # be fine-tuned.
      def error_messages_for_with_untaint(*args)
        error_messages_for_without_untaint(*args).untaint
      end
      alias_method_chain :error_messages_for, :untaint
    end
  end
end
