module SimplyHelpful
  module RecordIdentifier
    extend self

    def named_route(record, url_writer)
      record.new_record? ? 
        url_writer.send(plural_class_name(record)   + "_url") : 
        url_writer.send(singular_class_name(record) + "_url", record)
    end

    def partial_path(record_or_class)
      klass = record_or_class.is_a?(Class) ? record_or_class : record_or_class.class
      "#{klass.name.tableize}/#{klass.name.demodulize.underscore}"
    end

    def dom_class(record)
      singular_class_name(record)
    end

    def dom_id(record, prefix = nil) 
      prefix ||= 'new' unless record.id 
      [ prefix, singular_class_name(record), record.id ].compact * '_'
    end
  
    def plural_class_name(record)
      singular_class_name(record).pluralize
    end
  
    def singular_class_name(record)
      record.class.name.underscore.tr('/', '_')
    end
  end
end
