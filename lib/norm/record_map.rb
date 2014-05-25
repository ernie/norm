module Norm
  class RecordMap

    def initialize(records, keys)
      @storage = {}
      @keys    = Array(keys)
      records.each do |record|
        store(record)
      end
    end

    def size
      @storage.size
    end

    def fetch(record)
      @storage[record.attribute_values_at(*@keys)]
    end

    def store(record)
      keys = record.attribute_values_at(*@keys)
      validate_keys!(keys)
      @storage[keys] = record
    end

    private

    def validate_keys!(keys)
      if keys.any? { |key| key.nil? || Attribute::DEFAULT == key }
        raise ArgumentError, "All keys (#{@keys.join(', ')}) must be present"
      end
      if @storage.include?(keys)
        raise ArgumentError, "A record matching #{keys.inspect} already exists"
      end
    end

  end
end
