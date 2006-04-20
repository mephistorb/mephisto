module Technoweenie # :nodoc:
  module ActsAsDraftable
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods # :nodoc:
      # == Configuration options
      #
      # * <tt>fields</tt> - fields to save in the draft
      # * <tt>class_name</tt> - versioned model class name (default: Page::Draft in the above example)
      # * <tt>table_name</tt> - versioned model table name (default: page_drafts in the above example)
      # * <tt>foreign_key</tt> - foreign key used to relate the versioned model to the original model (default: page_id in the above example)
      # * <tt>sequence_name</tt> - name of the custom sequence to be used by the versioned model.
      def acts_as_draftable(options = {}, &extension)
        # don't allow multiple calls
        return if self.included_modules.include?(Technoweenie::ActsAsDraftable::ActMethods)

        send :include, Technoweenie::ActsAsDraftable::ActMethods
      
        cattr_accessor :draft_class_name, :draft_foreign_key, :draft_table_name, :draft_sequence_name, :drafted_fields

        self.draft_class_name    = options[:class_name]  || "Draft"
        self.draft_foreign_key   = options[:foreign_key] || self.to_s.foreign_key
        self.draft_table_name    = options[:table_name]  || "#{table_name_prefix}#{base_class.name.demodulize.underscore}_drafts#{table_name_suffix}"
        self.draft_sequence_name = options[:sequence_name]
        self.drafted_fields      = options[:fields]

        if block_given?
          extension_module_name = "#{draft_class_name}Extension"
          silence_warnings do
            self.const_set(extension_module_name, Module.new(&extension))
          end
      
          options[:extend] = self.const_get(extension_module_name)
        end
      
        has_one :draft, :class_name => "#{self.to_s}::#{draft_class_name}", :foreign_key => draft_foreign_key
        after_save { |record| record.draft.destroy if record.draft }
      
        # create the dynamic draft model
        draft_class = Class.new(ActiveRecord::Base) { cattr_accessor :draft_parent }
        draft_class.draft_parent = self
        draft_class.class_eval do
          class << self
            def draft_parent_name
              @draft_parent_name ||= draft_parent.name.underscore
            end

            def reloadable? ; false ; end

            def find_new(*args)
              with_new_drafts { find(*args) }
            end
  
            def count_new(*args)
              with_new_drafts { count(*args) }
            end
            
            protected
              def with_new_drafts(&block)
                with_scope(:find => { :conditions => "#{draft_parent.draft_table_name}.#{draft_parent.draft_foreign_key} IS NULL" }, &block)
              end
          end

          belongs_to        draft_parent_name.to_sym, :class_name => "::#{draft_parent.name}", :foreign_key => draft_parent.draft_foreign_key
          set_table_name    draft_parent.draft_table_name
          set_sequence_name draft_parent.draft_sequence_name if draft_parent.draft_sequence_name
          
          def draft_parent_name
            self.class.draft_parent_name
          end
        
          def drafted_field_values
            draft_parent.drafted_fields.inject({}) { |params, field| params.merge field => send(field) }
          end

          define_method "to_#{draft_parent_name}" do
            send("#{draft_parent_name}=", self.class.parent.new) if send(draft_parent_name).nil?
            send(draft_parent_name).draft = self
            send(draft_parent_name).load_from_draft
            send(draft_parent_name)
          end
        end

        draft_class.send :include,    options[:extend]    if options[:extend].is_a?(Module)
        const_set(draft_class_name, draft_class)
      end
    end

    # These Act Methods are the methods added to the model class.  The methods directly under ActMethods are instance methods.
    module ActMethods
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      # Saves this record's drafted fields in a new draft
      def save_draft
        (draft || build_draft).update_attributes drafted_field_values
      end

      # Saves the record's drafted fields in a new draft with #save!
      def save_draft!
        (draft || build_draft).attributes = drafted_field_values
        draft.save!
      end

      # Loads the latest drafted field values from the record's draft
      def load_from_draft
        self.attributes = draft.drafted_field_values if draft
      end

      # Loads the latest drafted field values and saves the current record
      def save_from_draft
        load_from_draft
        save
      end

      # Same as #save_from_draft, only it calls #save! instead.
      def save_from_draft!
        load_from_draft
        save!
      end

      # A hash of the current drafted field values of this model
      def drafted_field_values
        drafted_fields.inject({}) { |params, field| params.merge field => send(field) }
      end

      # These are class methods that are mixed in with the model class.
      module ClassMethods # :nodoc:
        # Returns an array of columns that are versioned.  See non_versioned_fields
        def draft_columns
          @draft_columns ||= drafted_fields.collect { |f| columns_hash[f.to_s] }
        end

        # Returns an instance of the dynamic versioned model
        def draft_class
          @draft_class ||= const_get(draft_class_name)
        end

        # Rake migration task to create the draft table using options passed to acts_as_draftable
        def create_draft_table(create_table_options = {})
          connection.create_table(draft_table_name, create_table_options) do |t|
            t.column draft_foreign_key, :integer
            t.column :updated_at, :datetime
            draft_columns.each do |col|
              t.column col.name, col.type, :limit => col.limit, :default => col.default
            end
          end
        end
    
        # Rake migration task to drop the versioned table
        def drop_draft_table
          connection.drop_table draft_table_name
        end
      end
    end
  end
end