module Norm
  class Repository

    class << self

      def primary_keys=(key_or_keys)
        keys = Array(key_or_keys).map(&:to_s)
        define_method(:primary_keys) { keys }
      end
      alias :primary_key= :primary_keys=

      def record_class=(record_class)
        define_method(:record_class) { record_class }
      end

    end

    def load_attributes(attributes)
      attributes.each do |name, value|
        attributes[name] = record_class.load_attribute(name, value)
      end
      attributes
    end

    def record_class
      raise NotImplementedError,
        'Repositories must set their record class with self.record_class='
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

    def store(record_or_records)
      raise NotImplementedError, 'Repositories must implement #store'
    end

    def insert(record_or_records)
      raise NotImplementedError, 'Repositories must implement #insert'
    end

    def update(record_or_records)
      raise NotImplementedError, 'Repositories must implement #update'
    end

    def delete(record_or_records)
      raise NotImplementedError, 'Repositories must implement #delete'
    end

  end
end

require 'norm/memory_repository'
require 'norm/postgresql_repository'
