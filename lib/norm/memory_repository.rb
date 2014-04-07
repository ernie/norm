module Norm
  class MemoryRepository < Repository

    def initialize(store = {})
      @store = store
    end

    def all
      @store.values.map { |tuple| record_class.from_repo(tuple) }
    end

    def store(record_or_records)
      to_update, to_insert = Array(record_or_records).partition(&:stored?)
      insert(to_insert)
      update(to_update)
    end

    def insert(record_or_records)
      Array(record_or_records).each do |record|
        attrs = stringify_values(record.initialized_attributes)
        set_defaults!(attrs)
        key = attrs.values_at(*primary_keys)
        require_insertable_key!(key)
        timestamp_insert!(attrs, record)
        @store[key] = attrs
        record.set_attributes(attrs)
        record.inserted!
      end
    end

    def update(record_or_records)
      Array(record_or_records).each do |record|
        attrs = stringify_values(record.initialized_attributes)
        set_defaults!(attrs)
        key = attrs.values_at(*primary_keys)
        require_updateable_key!(key)
        timestamp_update!(attrs, record)
        @store[key] = attrs
        record.set_attributes(attrs)
        record.updated!
      end
    end

    def fetch(*keys)
      if tuple = @store[keys.map(&:to_s)]
        record_class.from_repo(tuple)
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

    def require_insertable_key!(key)
      require_non_nil_key!(key)
      require_absent_key!(key)
    end

    def require_updateable_key!(key)
      require_non_nil_key!(key)
      require_present_key!(key)
    end

    def require_non_nil_key!(key)
      if key.any?(&:nil?)
        raise ArgumentError, "A primary key is nil: #{key.join('-')}"
      end
    end

    def require_absent_key!(key)
      if @store.key?(key)
        raise ArgumentError, "Duplicate primary key: #{key.join('-')}"
      end
    end

    def require_present_key!(key)
      unless @store.key?(key)
        raise ArgumentError, "No result found for key: #{key.join('-')}"
      end
    end

    def timestamp_insert!(attrs, record)
      if record.attribute?(:created_at)
        attrs['created_at'] = Attr::Timestamp.now.to_s
      end
      timestamp_update!(attrs, record)
    end

    def timestamp_update!(attrs, record)
      if record.attribute?(:updated_at)
        attrs['updated_at'] = Attr::Timestamp.now.to_s
      end
    end

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
      (record_class.attribute_names - attrs.keys).each do |attr|
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
