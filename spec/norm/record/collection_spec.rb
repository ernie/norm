require 'spec_helper'

module Norm
  class Record
    describe Collection do
      let(:person_record_class) {
        Class.new(Record) {
          attribute :id,   Attr::Integer
          attribute :name, Attr::String
          attribute :age,  Attr::Integer
        }
      }
      let(:ernie) {
        person_record_class.new(:id => 1, :name => 'Ernie', :age => 36)
      }
      let(:bert) {
        person_record_class.new(:id => 2, :name => 'Bert', :age => 37)
      }
      let(:oscar) {
        person_record_class.new(:id => 3, :name => 'Oscar', :age => 38)
      }
      let(:records) {
        [ernie, bert, oscar]
      }
      let(:person_collection_class) { person_record_class::Collection }
      subject { person_collection_class.new(records) }

      describe 'initialization' do

        it 'is empty when no records are supplied' do
          person_collection_class.new.must_be :empty?
        end

        it 'has one record when a single record is supplied' do
          person_collection_class.new(ernie).size.must_equal 1
          subject.first.must_equal ernie
        end

        it 'has the records in the array when an array is supplied' do
          subject.size.must_equal 3
          subject.to_a.must_equal records
        end

        it 'freezes its records without freezing the passed-in array' do
          subject.records.must_be :frozen?
          records.wont_be :frozen?
        end

      end

      describe '#insert_attributes' do

        it 'batch updates attributes in order provided' do
          records = person_collection_class.new(
            2.times.map { person_record_class.new }
          )
          records.insert_attributes(
            [
              {:id => 1, :name => 'Ernie', :age => 36},
              {:id => 2, :name => 'Bert', :age => 37}
            ]
          )
          records.to_a.must_equal [ernie, bert]
        end

        it 'raises ArgumentError if differing number of records and attrs' do
          records = person_collection_class.new(
            2.times.map { person_record_class.new }
          )
          error = proc {
            records.insert_attributes(
              [
                {:id => 1, :name => 'Ernie', :age => 36},
                {:id => 2, :name => 'Bert', :age => 37},
                {:id => 3, :name => 'Oscar', :age => 38}
              ]
            )
          }.must_raise ArgumentError
          error.message.must_equal '3 attribute sets, but 2 records'
        end

      end

      describe '#set_attributes' do

        it 'batch updates attributes that match by identity' do
          subject.set_attributes([{:id => 1, :name => 'Ernest'}])
          ernie.name.must_equal 'Ernest'
        end

      end

      describe '#set' do

        it 'batch updates attributes that match by identity using setters' do
          person_record_class.class_eval do
            def name=(name)
              super("#{name}-diddly")
            end
          end
          subject.set([{:id => 1, :name => 'Ernest'}])
          ernie.name.must_equal 'Ernest-diddly'
        end

      end

      describe '#stored!' do

        it 'flags all records as stored' do
          subject.stored!
          subject.records.all?(&:stored?).must_equal true
        end

        it 'returns the collection' do
          subject.stored!.must_be_same_as subject
        end

      end

      describe '#inserted!' do

        it 'inserts all records' do
          subject.records.each { |record| record.age += 1 }
          subject.records.all?(&:updated_attributes?).must_equal true
          subject.inserted!
          subject.records.all?(&:stored?).must_equal true
          subject.records.all?(&:updated_attributes?).must_equal false
        end

        it 'returns the collection' do
          subject.inserted!.must_be_same_as subject
        end

      end

      describe '#updated!' do

        it 'updates all records' do
          subject.inserted!
          subject.records.each { |record| record.age += 1 }
          subject.records.all?(&:updated_attributes?).must_equal true
          subject.updated!
          subject.records.all?(&:updated_attributes?).must_equal false
        end

        it 'returns the collection' do
          subject.updated!.must_be_same_as subject
        end

      end

      describe '#deleted!' do

        it 'deletes all records' do
          subject.inserted!
          subject.records.all?(&:deleted?).must_equal false
          subject.deleted!
          subject.records.all?(&:deleted?).must_equal true
        end

        it 'returns the collection' do
          subject.deleted!.must_be_same_as subject
        end

      end

      describe '#valid?' do

        it 'is true for an empty collection' do
          person_collection_class.new.must_be :valid?
        end

        it 'is true for a collection of valid records' do
          subject.must_be :valid?
        end

        it 'is false if any records are invalid' do
          record = subject.records.first
          def record.valid?
            false
          end
          subject.wont_be :valid?
        end

      end

      describe '#stored?' do

        it 'is true for an empty collection' do
          person_collection_class.new.must_be :stored?
        end

        it 'is true for a collection of stored records' do
          subject.stored!
          subject.must_be :stored?
        end

        it 'is false if any records are not stored' do
          subject[0..1].each(&:stored!)
          subject.wont_be :stored?
        end

      end

      describe '#deleted?' do

        it 'is true for an empty collection' do
          person_collection_class.new.must_be :deleted?
        end

        it 'is true for a collection of deleted records' do
          subject.deleted!
          subject.must_be :deleted?
        end

        it 'is false if any records are not deleted' do
          subject[0..1].each(&:deleted!)
          subject.wont_be :deleted?
        end

      end

      describe '#to_a' do

        it 'returns a duplicate copy of the array it was initialized with' do
          array = subject.to_a
          array.must_equal records
          array.wont_be_same_as records
        end

      end

      describe '#each' do

        it 'delegates to the array it contains' do
          array = subject.each.to_a
          array.must_equal records
        end

      end

      describe '#empty?' do

        it 'is true when the collection is empty' do
          subject.wont_be :empty?
          person_record_class::Collection.new.must_be :empty?
        end

      end

      describe '#size' do

        it 'returns the number of records contained in the collection' do
          subject.size.must_equal records.size
        end

      end

      describe '#first' do

        it 'returns the first record in the collection' do
          subject.first.must_equal ernie
        end

      end

      describe '#last' do

        it 'returns the last record in the collection' do
          subject.last.must_equal oscar
        end

      end

      describe '#[]' do

        it 'retrieves a record based on its index' do
          subject[1].must_equal bert
        end

      end

      describe '#==' do
        it 'needs specs' do
          skip 'these are boring to write and I should make a helper'
        end
      end

      describe '#eql?' do
        it 'needs specs' do
          skip 'these are boring to write and I should make a helper'
        end
      end

      describe '#hash' do
        it 'needs specs' do
          skip 'these are boring to write and I should make a helper'
        end
      end

      describe 'Collection()' do

        it 'returns the existing collection if a collection is received' do
          Record::Collection(subject).must_be_same_as subject
        end

        it 'returns a collection with class of the first record with array' do
          collection = Record::Collection(records)
          collection.must_be_kind_of(person_record_class::Collection)
          collection.must_equal subject
        end

        it 'returns an empty Record::Collection for an empty array' do
          collection = Record::Collection([])
          collection.class.must_equal Record::Collection
          collection.must_be :empty?
        end

      end

      describe 'an empty Record::Collection' do
        let(:person_record_collection) { person_record_class::Collection.new }
        subject { Record::Collection.new }

        it 'is equal to an empty subclass' do
          subject.must_equal person_record_collection
        end

        it 'is not eql? to an empty subclass' do
          subject.wont_be :eql?, person_record_collection
        end

        it 'does not have the same hash as an empty subclass' do
          subject.hash.wont_equal person_record_collection.hash
        end

      end

    end
  end
end
