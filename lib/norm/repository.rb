module Norm
  class Repository
    NoRecordClassError = Class.new(Error)

    class << self

      def primary_keys=(key_or_keys)
        keys = Array(key_or_keys).map(&:to_s)
        define_method(:primary_keys) { keys }
      end
      alias :primary_key= :primary_keys=

      def default_record_class=(record_class)
        define_method(:default_record_class) { record_class }
      end

    end

    attr_reader :record_class

    def initialize(record_class = nil)
      @record_class = record_class || default_record_class
      require_record_class!
    end

    def load_attributes(attributes)
      attributes.each do |name, value|
        attributes[name] = record_class.load_attribute(name, value)
      end
      attributes
    end

    def default_record_class
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

    private

    def require_record_class!
      unless record_class
        raise NoRecordClassError,
          'Record class required. Set one, or specify default_record_class.'
      end
    end

  end
end

require 'norm/memory_repository'
require 'norm/postgresql_repository'
