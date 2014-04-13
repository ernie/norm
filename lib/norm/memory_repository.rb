require 'norm/memory_store'

module Norm
  class MemoryRepository < Repository

    def initialize(record_class = nil, store = nil)
      super(record_class)
      @store = store || MemoryStore.new(self.record_class, *primary_keys)
    end

    def all
      @store.select { true }.map { |tuple| record_class.from_repo(tuple) }
    end

    def store(record_or_records)
      to_update, to_insert = Array(record_or_records).partition(&:stored?)
      insert(to_insert) + update(to_update)
    end

    def insert(record_or_records)
      records = Array(record_or_records)
      @store.insert(record_or_records).zip(records).map { |tuple, record|
        record.set_attributes(tuple)
        record.inserted!
      }
    end

    def update(record_or_records)
      records = Array(record_or_records)
      update_map = record_map(records)
      records.group_by(&:updated_attributes).flat_map { |attrs, records|
        if attrs.empty?
          []
        else
          @store.update(attrs) { |record| records.detect { |r|
              r.attribute_values(*primary_keys) ==
                record.attribute_values(*primary_keys)
            } }.
            each { |tuple|
            updated = record_class.from_repo(tuple)
            if record = update_map[updated.attribute_values(*primary_keys)]
              record.set_attributes(updated.initialized_attributes)
              record.updated!
            end
          }
        end
      }
      records
    end

    def fetch(*keys)
      attributes = load_attributes(Hash[primary_keys.zip(keys)])
      if tuple = @store.fetch(keys)
        record_class.from_repo(tuple)
      end
    end

    def delete(record_or_records)
      records = Array(record_or_records)
      delete_map = record_map(records)
      @store.delete { |record| records.include?(record) }.each { |tuple|
        deleted = record_class.from_repo(tuple)
        if record = delete_map[deleted.attribute_values(*primary_keys)]
          record.set_attributes(deleted.initialized_attributes)
          record.deleted!
        end
      }
      records
    end

    private

    def record_map(records)
      Hash[records.map { |record|
        [record.attribute_values(*primary_keys), record]
      }]
    end

  end
end
