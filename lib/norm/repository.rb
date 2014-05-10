module Norm
  class Repository

    attr_reader :record_class, :connection_manager

    def initialize(record_class = nil,
                   connection_manager: Norm.connection_manager)
      @record_class, @connection_manager = record_class, connection_manager
    end

    def with_connection(*args, &block)
      connection_manager.with_connection(*args, &block)
    end

    def with_connections(*args, &block)
      connection_manager.with_connections(*args, &block)
    end

    def atomically_on(*args, &block)
      connection_manager.atomically_on(*args, &block)
    end

    def load_attributes(attributes)
      attributes.each do |name, value|
        attributes[name] = record_class.load_attribute(name, value)
      end
      attributes
    end

    def primary_keys
      record_class.identifying_attribute_names
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

    def mass_store(records)
      raise NotImplementedError, 'Repositories must implement #mass_store'
    end

    def insert(record)
      raise NotImplementedError, 'Repositories must implement #insert'
    end

    def mass_insert(records)
      raise NotImplementedError, 'Repositories must implement #mass_insert'
    end

    def update(record)
      raise NotImplementedError, 'Repositories must implement #update'
    end

    def mass_update(records, attrs = nil)
      raise NotImplementedError, 'Repositories must implement #mass_update'
    end

    def delete(record)
      raise NotImplementedError, 'Repositories must implement #delete'
    end

    def mass_delete(records)
      raise NotImplementedError, 'Repositories must implement #mass_delete'
    end

    def returning_result(&block)
      raise NotImplementedError, 'Repositories must implement #returning_result'
    end

  end
end

require 'norm/postgresql_repository'
