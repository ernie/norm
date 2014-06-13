module Norm
  class Record
    class Collection
      attr_reader :records

      def initialize(records = nil)
        @records = Array(records).dup.freeze
      end

      def self.constraints
        rules = Constraint::RuleSet.new
        yield rules
        define_method(:constraint_rule_for) { |error|
          rules.match(error) || super(error)
        }
      end

      def record_class
        Record
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
        with_matching_records(attributes) do |record, match|
          record.set_attributes(match.initialized_attributes)
        end
      end

      def set(attributes)
        with_matching_records(attributes) do |record, match|
          record.set(match.initialized_attributes)
        end
      end

      def stored!
        records.each(&:stored!)
        self
      end

      def stored?
        records.all?(&:stored?)
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

      def deleted?
        records.all?(&:deleted?)
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
          self.records == other.records
      end

      def eql?(other)
        self.class.eql?(other.class) &&
          self.records.eql?(other.records)
      end

      def hash
        self.class.hash ^ self.records.hash
      end

      private

      def with_matching_records(attributes)
        return self unless records.any?
        matching = record_map(attributes)
        records.each do |record|
          if match = matching[record]
            yield record, match
          end
        end
        self
      end

      def record_map(attributes)
        Hash[
          attributes.map { |attrs|
            record = record_class.new(attrs)
            [record, record]
          }
        ]
      end

    end

    def self.Collection(records)
      if Collection === records
        records
      else
        records = Array(records)
        if records.empty?
          Collection.new(records)
        else
          records.first.class::Collection.new(records)
        end
      end
    end

  end
end
