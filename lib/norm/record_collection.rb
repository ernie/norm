module Norm
  class RecordCollection
    attr_reader :record_class, :records

    def initialize(records = nil, record_class: nil)
      @records = Array(records)
      @record_class = record_class || infer_record_class(@records.first)
    end

    def insert_attributes(attributes)
      attributes = Array(attributes)
      if attributes.size != records.size
        raise ArgumentError,
          "#{attributes.size} attribute sets, but #{records.size} records"
      end
      records.zip(attributes).each do |record, attrs|
        record.set_attributes(attrs)
      end
      self
    end

    def set_attributes(attributes)
      matching = Hash[attributes.map { |attrs|
        record = record_class.new(attrs)
        [record, record]
      }]
      records.each do |record|
        if match = matching[record]
          record.set_attributes(match.initialized_attributes)
        end
      end
      self
    end

    def set(attributes)
      matching = Hash[attributes.map { |attrs|
        record = record_class.new(attrs)
        [record, record]
      }]
      records.each do |record|
        if match = matching[record]
          record.set(match.initialized_attributes)
        end
      end
      self
    end

    def stored!
      records.each(&:stored!)
      self
    end

    def inserted!
      records.each(&:inserted!)
      self
    end

    def updated!
      records.each(&:updated!)
      self
    end

    def deleted!
      records.each(&:deleted!)
      self
    end

    def valid?
      records.all?(&:valid?)
    end

    def constraint_rule_for(error)
      nil
    end

    def constraint_error(error)
      nil
    end

    def to_a
      records.dup
    end

    def each(&block)
      records.each(&block)
    end

    def empty?
      records.empty?
    end

    def size
      records.size
    end

    def first
      records.first
    end

    def last
      records.last
    end

    def [](index)
      records[index]
    end

    def ==(other)
      !!(self.class <=> other.class) &&
        self.record_class == other.record_class &&
        self.records == other.records
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        self.record_class.eql?(other.record_class) &&
        self.records.eql?(other.records)
    end

    def hash
      self.class.hash ^ self.record_class ^ self.records.hash
    end

    private

    def infer_record_class(first_record)
      if first_record
        first_record.class
      else
        raise ArgumentError, "Can't infer record class from empty array!"
      end
    end

  end

  def self.RecordCollection(records)
    if RecordCollection === records
      records
    else
      RecordCollection.new(records)
    end
  end

end
