module Norm
  class Repository

    attr_reader :record_class, :connection_manager, :processor, :reader, :writer

    def initialize(record_class,
                   connection_manager: Norm.connection_manager,
                   processor: RecordMutationProcessor.new(record_class),
                   reader: :primary, writer: :primary)
      @record_class       = record_class
      @connection_manager = connection_manager
      @processor          = processor
      @reader, @writer    = reader, writer
    end

    def with_connection(name = reader, &block)
      connection_manager.with_connection(name, &block)
    end

    def with_connections(*args, &block)
      connection_manager.with_connections(*args, &block)
    end

    def atomically_on(*args, &block)
      connection_manager.atomically_on(*args, &block)
    end

    def load_attributes(attributes)
      record_class.new(attributes).get_attributes(*attributes.keys)
    end

    def attribute_names
      record_class.attribute_names
    end

    def all
      raise NotImplementedError, 'Repositories must implement #all'
    end

    def fetch(*keys)
      raise NotImplementedError, 'Repositories must implement #fetch'
    end

    def store(record)
      raise NotImplementedError, 'Repositories must implement #store'
    end

    def insert(record)
      raise NotImplementedError, 'Repositories must implement #insert'
    end

    def update(record)
      raise NotImplementedError, 'Repositories must implement #update'
    end

    def delete(record)
      raise NotImplementedError, 'Repositories must implement #delete'
    end

  end
end

require 'norm/postgresql_repository'
