module ModelStubbing
  # Stubs hold custom attributes that are applied to models when
  # instantiated.  By default, accessing the same stub twice
  # will return the exact same instance.  However, custom attributes
  # will create unique stub instances.
  class Stub
    attr_reader   :model
    attr_reader   :attributes
    attr_reader   :global_key
    attr_accessor :name
    
    # Creates a new stub.  If it's not the default, it inherits the default 
    # stub's attributes.
    def initialize(model, name, attributes)
      @model      = model
      @name       = name
      @attributes = 
        if default? || model.default.nil?
          attributes
        else
          model.default.attributes.merge(attributes)
        end

      @global_key = (name == :default ? @model.singular : "#{name}_#{@model.singular}").to_sym
      @model.all_stubs[@global_key] = @model.stubs[name] = self
    end
    
    def dup(model = nil)
      Stub.new(model || @model, @name, @attributes)
    end
    
    def ==(stub)
      (stub.object_id == object_id) ||
        (stub.is_a?(Stub) && stub.model.name == @model.name && stub.global_key == @global_key && stub.name == @name && stub.attributes == @attributes)
    end
    
    def default?
      @name == :default
    end
    
    # Retrieves or creates a record based on the stub's set attributes and the given custom attributes.
    def record(attributes = {})
      attributes.empty? && ModelStubbing.records.key?(record_key(attributes)) ? retrieve(attributes) : instantiate(attributes)
    end
    
    def inspect
      "(ModelStubbing::Stub(#{@name.inspect} => #{attributes.inspect}))"
    end
    
    def insert(attributes = {})
      object = record(attributes)
      connection.insert_fixture(object.stubbed_attributes, model.model_class.table_name)
    end
    
    def with(attributes)
      @attributes.inject({}) do |attr, (key, value)|
        attr_value = attributes[key] || value
        attr_value = attr_value.record if attr_value.is_a?(Stub)
        attr.update key => attr_value
      end
    end
    
    def only(*keys)
      keys = Set.new Array(keys)
      @attributes.inject({}) do |attr, (key, value)|
        if keys.include?(key)
          attr.update key => (value.is_a?(Stub) ? value.record : value)
        else
          attr
        end
      end
    end
    
    def except(*keys)
      keys = Set.new Array(keys)
      @attributes.inject({}) do |attr, (key, value)|
        if keys.include?(key)
          attr
        else
          attr.update key => (value.is_a?(Stub) ? value.record : value)
        end
      end
    end
    
    def connection
      @connection ||= @model.connection
    end
  
  private
    def instantiate(attributes)
      default_record     = attributes.empty?
      stubbed_attributes = stubbed_attributes(@attributes.merge(attributes))

      record = @model.model_class.new
      meta   = class << record
        attr_accessor :stubbed_attributes
        def new_record?() false end
        self
      end
      
      record.id = @model.model_class.mock_id
      record.stubbed_attributes = stubbed_attributes.merge(:id => record.id)
      stubbed_attributes.each do |key, value|
        if value.is_a? Stub
          # set foreign key
          record[stubbed_attributes.column_name_for(key)] = value.record.id
          # set association
          meta.send :attr_accessor, key unless record.respond_to?("#{key}=")
          record.send("#{key}=", value.is_a?(Stub) ? value.record : value)
        else
          record[key] = value
        end
      end
   
      ModelStubbing.records[record_key(attributes)] = record if default_record
      record
    end
    
    def stubbed_attributes(attributes)
      attributes.inject FixtureHash.new(self) do |stubbed, (key, value)|
        stubbed.update key => value
      end
    end
    
    def retrieve(attributes = {})
      ModelStubbing.records[record_key(attributes)]
    end
    
    # so that duped stubs with duplicate attributes reuse the same record
    def record_key(attributes)
      @record_key ||= [model.model_class.name, @global_key, @attributes.merge(attributes).inspect] * ":"
    end
  end
  
  class FixtureHash < Hash
    def initialize(stub)
      super()
      @stub = stub
    end

    def key_list
      keys.collect { |key| @stub.connection.quote_column_name(column_name_for(key)) } * ", "
    end

    def value_list
      list = inject([]) do |fixtures, (key, value)|
        column_name = column_name_for key
        column      = column_for column_name
        value       = value.record.id if value.is_a?(Stub)
        fixtures << @stub.connection.quote(value, column).gsub('[^\]\\n', "\n").gsub('[^\]\\r', "\r")
      end.join(", ")
    end

    def column_name_for(key)
      (@keys ||= {})[key] ||= begin
        value = self[key]
        if value.is_a? Stub
          if defined?(ActiveRecord)
            reflection = model_class.reflect_on_association(key)
            reflection.primary_key_name
          else
            "#{key}_id"
          end
        else
          key
        end
      end
    end
  
    def column_for(name)
      model_class.columns_hash[name] if defined?(ActiveRecord) && model_class.ancestors.include?(ActiveRecord::Base)
    end
  
  private
    def model_class
      @stub.model.model_class
    end
  end
end