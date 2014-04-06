module Norm
  class Repository

    class << self

      def primary_keys(*keys)
        keys.map!(&:to_s)
        define_method(:primary_keys) { keys }
      end
      alias :primary_key :primary_keys

    end

    primary_key :id

    def all
      raise NotImplementedError, 'Repositories must implement #all'
    end

    def fetch(*keys)
      raise NotImplementedError, 'Repositories must implement #fetch'
    end

    def store(record_or_records)
      raise NotImplementedError, 'Repositories must implement #store'
    end

    def delete(record_or_records)
      raise NotImplementedError, 'Repositories must implement #delete'
    end

    def instantiate(tuples)
      raise NotImplementedError, 'Repositories must implement #instantiate'
    end

  end
end
