module ModelStubbing
  # Models hold one or more stubs.
  class Model
    attr_reader   :definition
    attr_accessor :name
    attr_accessor :plural
    attr_accessor :singular
    attr_reader   :stubs
    attr_reader   :model_class

    # Creates a stub for this model.  A stub with no name is assumed to be the default
    # stub.  A global key for the definition is also created based on the singular
    # form of the stub name.  
    def stub(name = nil, options = {})
      if name.is_a?(Hash)
        options = name
        name    = :default
      end

      Stub.new(self, name, options)
    end

    def initialize(definition, klass, options = {}, &block)
      @definition  = definition
      @model_class = klass
      @name        = options[:name]     || klass.table_name.to_sym
      @plural      = options[:plural]   || name
      @singular    = options[:singular] || name.to_s.singularize
      @stubs       = {}
      unless @model_class.respond_to?(:mock_id)
        class << @model_class
          define_method :mock_id do
            @mock_id ||= 999
            @mock_id  += 1
          end
        end
      end
      instance_eval &block if block
    end
    
    def dup(definition = nil)
      copy = self.class.new(definition || @definition, @model_class, :name => @name, :plural => @plural, :singular => @singular)
      stubs.each do |key, value|
        copy.stubs[key] = value.dup(copy)
      end
      copy
    end
    
    def ==(model)
      (model.object_id == object_id) ||
        (model.is_a?(Model) && model.name == @name && model.model_class == @model_class)
    end
    
    # References the default stub for this model.
    def default
      @stubs[:default]
    end
    
    # Accesses the current mocked time for this definition.
    def current_time
      @definition.current_time
    end
    
    # Shortcut to all the stubs for the definition.
    def all_stubs(key = nil)
      key ? @definition.stubs[key] : @definition.stubs
    end

    # Instantiates a stub into a new record.
    def retrieve_record(key, attributes = {})
      @stubs[key].record(attributes)
    end
    
    def stub_method_definition
      "def #{@plural}(key, attributes = {}) self.class.definition.models[#{@plural.inspect}].retrieve_record(key, attributes) end"
    end

    def inspect
      "(ModelStubbing::Model(#{@name.inspect} => [#{@stubs.keys.collect { |k| k.to_s }.sort.join(", ")}]))"
    end
    
    def insert
      purge
      @stubs.values.each &:insert
    end
    
    def purge
      model_class.connection.execute "TRUNCATE TABLE #{connection.quote_column_name model_class.table_name}"
    end
    
    def connection
      @connection ||= model_class.connection
    end
  end
end