module Norm
  class MemoryStore

    def initialize(record_class, *primary_keys)
      @record_class, @primary_keys = record_class, primary_keys.map(&:to_s)
      @records = {}
      @serials = Hash.new { |h, k| h[k] = (1..Float::INFINITY).to_enum }
    end

    def fetch(key)
      if record = @records[key]
        record.attributes
      end
    end

    def select(&block)
      @records.values.select(&block).map(&:attributes)
    end

    def select_records(&block)
      @records.values.select(&block)
    end

    def insert(record_or_records)
      working = {}
      returning = Array(record_or_records).map do |record|
        new_record = @record_class.new(record.initialized_attributes)
        set_defaults!(new_record)
        insert_triggers!(new_record)
        validate_for_insert!(new_record)
        working[extract_key(new_record)] = new_record
        new_record.attributes
      end
      working.values.map(&:inserted!)
      @records.merge!(working)
      returning
    end

    def update(attrs, &block)
      working = {}
      returning = select_records(&block).map do |record|
        new_record = @record_class.new(record.initialized_attributes)
        set_defaults!(new_record)
        update_triggers!(new_record)
        new_record.set_attributes(attrs)
        validate_for_update!(record, new_record)
        working[extract_key(new_record)] = new_record
        new_record.attributes
      end
      working.values.map(&:updated!)
      @records.merge!(working)
      returning
    end

    def delete(&block)
      to_delete = []
      returning = select_records(&block).map do |record|
        new_record = @record_class.new(record.initialized_attributes)
        delete_triggers!(new_record)
        validate_for_delete!(new_record)
        to_delete << extract_key(record)
        new_record.attributes
      end
      @records.delete_if { |k, v| to_delete.include?(k) }
      returning
    end

    def set_defaults!(record)
      (record.attribute_names - record.initialized_attribute_names).each do |a|
        if respond_to?("default_#{a}")
          record.send("#{a}=", send("default_#{a}"))
        end
      end
    end

    def next_serial(name)
      @serials[name.to_s].next
    end

    def extract_key(record)
      record.attribute_values(*@primary_keys)
    end

    def insert_triggers!(record)
    end

    def update_triggers!(record)
    end

    def delete_triggers!(record)
    end

    # Simulate DB constraints that would throw an error on insert by raising an
    # appropriate one here.
    def validate_for_insert!(record)
      key = record.attribute_values(*@primary_keys)
      key.none?(&:nil?) or
        raise InvalidKeyError, "A primary key value was nil"
      if @records.key?(key)
        raise DuplicateKeyError, "This primary key is a duplicate"
      end
    end

    # Simulate DB constraints that would throw an error on update by raising an
    # appropriate one here.
    def validate_for_update!(old_record, new_record)
      old_key = old_record.attribute_values(*@primary_keys)
      new_key = new_record.attribute_values(*@primary_keys)
      new_key.none?(&:nil?) or
        raise InvalidKeyError, "A primary key value was nil"
      if old_key != new_key && @records.key?(new_key)
        raise DuplicateKeyError, "This primary key is a duplicate"
      end
    end

    # Simulate DB constraints that would throw an error on delete by raising an
    # appropriate one here.
    def validate_for_delete!(record)
    end

  end
end
