require 'spec_helper'

module Norm
  describe RecordMap do

    let(:record_class) {
      Class.new(Record) {
        attribute :key1,  Attr::Integer
        attribute :key2,  Attr::Integer
        attribute :value, Attr::String
        identity  :key1, :key2
      }
    }

    let(:records) {
      (1..5).map { |i|
        record_class.new(:key1 => i, :key2 => i ** 2, :value => 'x' * i)
      }
    }

    describe 'initialization' do
      subject { RecordMap }

      it 'requires records and keys arguments' do
        proc { subject.new }.must_raise ArgumentError
        proc { subject.new [] }.must_raise ArgumentError
        subject.new([], []).must_be_kind_of RecordMap
      end

      it 'stores the provided records in the map' do
        subject.new(records, [:key1, :key2]).size.must_equal 5
      end

    end

    subject { RecordMap.new(records, [:key1, :key2]) }

    describe '#size' do

      it 'returns the number of records in the map' do
        RecordMap.new([], []).size.must_be :zero?
        subject.size.must_equal 5
      end

    end

    describe '#fetch' do

      it 'retrieves a matching record from the map if present' do
        record = record_class.new(:key1 => 2, :key2 => 4)
        match = subject.fetch(record)
        match.must_be_same_as records[1]
      end

      it 'returns nil if no matching record is present' do
        record = record_class.new(:key1 => 1, :key2 => 5)
        match = subject.fetch(record)
        match.must_be_nil
      end

    end

    describe '#store' do

      it 'stores a record with valid keys in the map' do
        record = record_class.new(:key1 => 6, :key2 => 36, :value => 'xxxxxx')
        subject.store(record)
        subject.size.must_equal 6
      end

      it 'raises ArgumentError if a record has a nil or default key' do
        record = record_class.new(:key1 => 6, :key2 => nil, :value => 'xxxxxx')
        error = proc { subject.store(record) }.must_raise ArgumentError
        error.message.must_equal 'All keys (key1, key2) must be present'
        record.key2 = Attribute::DEFAULT
        error = proc { subject.store(record) }.must_raise ArgumentError
        error.message.must_equal 'All keys (key1, key2) must be present'
      end

      it 'raises ArgumentError if a record has a duplicate key' do
        record = record_class.new(:key1 => 1, :key2 => 1, :value => 'x')
        error = proc { subject.store(record) }.must_raise ArgumentError
        error.message.must_equal 'A record matching [1, 1] already exists'
      end

    end

  end
end
