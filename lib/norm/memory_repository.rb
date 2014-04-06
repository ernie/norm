module Norm
  class MemoryRepository < Repository

    def initialize(instantiator, store = {})
      super(instantiator)
      @store = store
    end

    def all
      @store.values.map { |tuple| @instantiator.from_repo(tuple) }
    end

    def store(record_or_records)
      to_update, to_insert = Array(record_or_records).partition { |record|
        record.stored?
      }
      insert(to_insert)
      update(to_update)
    end

    def insert(record_or_records)
      Array(record_or_records).each do |record|
        attrs = stringify_values(record.initialized_attributes)
        set_defaults!(attrs)
        key = attrs.values_at(*primary_keys)
        if @store.key?(key)
          raise ArgumentError, "Duplicate primary key #{key.join('-')}"
        elsif key.any?(&:nil?)
          raise ArgumentError, "A primary key is nil: #{key.join('-')}"
        else
          timestamp!(
            attrs,
            record.attribute_names & ['created_at', 'updated_at']
          )
          @store[key] = attrs
          record.set_attributes(attrs)
          record.inserted!
        end
      end
    end

    def update(record_or_records)
      Array(record_or_records).each do |record|
        attrs = stringify_values(record.initialized_attributes)
        key = attrs.values_at(*primary_keys)
        if !@store.key?(key)
          raise ArgumentError, "No result found for #{key.join('-')}"
        elsif key.any?(&:nil?)
          raise ArgumentError, "A primary key is nil: #{key.join('-')}"
        else
          timestamp!(
            attrs,
            record.attribute_names & ['updated_at']
          )
          @store[key] = attrs
          record.set_attributes(attrs)
          record.updated!
        end
      end
    end

    def fetch(*keys)
      if tuple = @store[keys.map(&:to_s)]
        @instantiator.from_repo(tuple)
      end
    end

    def delete(record_or_records)
      Array(record_or_records).each do |record|
        attrs = stringify_values(record.initialized_attributes)
        @store.delete(attrs.values_at(*primary_keys))
        record.deleted!
      end
    end

    private

    def default_id
      id_sequence.next
    end

    def id_sequence
      @id_sequence ||= (
        (max_int_attribute_value('id') + 1)..Float::INFINITY
      ).to_enum
    end

    def max_int_attribute_value(key)
      @store.values.map { |v| v[key].to_i }.max || 0
    end

    def set_defaults!(attrs)
      (@instantiator.attribute_names - attrs.keys).each do |attr|
        if respond_to?("default_#{attr}", true)
          new_value = send("default_#{attr}")
          attrs[attr] = new_value.nil? ? nil : new_value.to_s
        end
      end
    end

    def timestamp!(attrs, keys)
      timestamp = Attr::Timestamp.now.to_s
      keys.each { |key| attrs[key] = timestamp }
    end

    def stringify_values(attributes)
      Hash[ attributes.map { |k, v| [k, v.nil? ? v : v.to_s] } ]
    end

  end
end
