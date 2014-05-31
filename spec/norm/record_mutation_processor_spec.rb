require 'spec_helper'

module Norm
  describe RecordMutationProcessor do
    let(:person_record_class) {
      Class.new(Record) {
        attribute :id,   Attr::Integer
        attribute :name, Attr::String
        attribute :age,  Attr::Integer
      }
    }

    let(:no_tuples) {
      [].tap do |no_tuples|
        def no_tuples.ntuples
          0
        end
      end
    }

    let(:one_tuple) {
      [:id => '1', :name => 'Ernie', :age => '36'].tap do |one_tuple|
        def one_tuple.ntuples
          1
        end
      end
    }

    let(:two_tuples) {
      [
        {:id => '1', :name => 'Ernie', :age => '36'},
        {:id => '2', :name => 'Bert', :age => '37'}
      ].tap do |two_tuples|
        def two_tuples.ntuples
          2
        end
      end
    }

    subject { RecordMutationProcessor.new(person_record_class) }

    describe '#select_one process' do

      it 'returns a record from the first tuple' do
        subject.select_one do |process|
          record = process.call(one_tuple, nil)
          record.must_be_kind_of person_record_class
          record.all_attributes.must_equal(
            :id => 1, :name => 'Ernie', :age => 36
          )
        end
      end

      it 'returns nil if no tuples returned' do
        subject.select_one do |process|
          process.call(no_tuples, nil).must_be_nil
        end
      end

    end

    describe '#select_many process' do

      it 'returns a records from each tuple' do
        subject.select_many do |process|
          records = process.call(two_tuples, nil)
          records.map(&:all_attributes).must_equal(
            [
              {:id => 1, :name => 'Ernie', :age => 36},
              {:id => 2, :name => 'Bert', :age => 37}
            ]
          )
        end
      end

    end

    describe '#insert_one process' do

      it 'updates the passed-in record with the returned tuple' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert_one(record) do |process|
          process.call(one_tuple, nil)
        end
        record.must_be :stored?
        record.id.must_equal 1
      end

      it 'raises NotFoundError if no tuples returned' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise NotFoundError
        end
        record.wont_be :stored?
        record.id.must_be_nil
      end

      it 'raises TooManyResultsError if more than one tuple returned' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise TooManyResultsError
        end
        record.wont_be :stored?
        record.id.must_be_nil
      end

    end

    describe '#insert_many process' do
      it { skip 'needs to be implemented' }
    end

    describe '#update_one process' do

      it 'updates the passed-in record from the returned tuple' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        record.age = 37
        record.must_be :updated_attributes?
        subject.update_one(record) do |process|
          process.call(one_tuple, nil) # Returns age of 36
        end
        record.wont_be :updated_attributes?
        record.age.must_equal 36
      end

      it 'raises NotFoundError if no tuples returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        record.age = 37
        record.must_be :updated_attributes?
        subject.update_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise NotFoundError
        end
        record.must_be :updated_attributes?
        record.age.must_equal 37
      end

      it 'raises TooManyResultsError if more than one tuple returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        record.age = 37
        record.must_be :updated_attributes?
        subject.update_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise TooManyResultsError
        end
        record.must_be :updated_attributes?
        record.age.must_equal 37
      end

    end

    describe '#update_many process' do
      it { skip 'needs to be implemented' }
    end

    describe '#delete_one process' do

      it 'updates the passed-in record with the returned tuple' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        subject.delete_one(record) do |process|
          process.call(one_tuple, nil)
        end
        record.must_be :deleted?
        record.age.must_equal 36
      end

      it 'raises NotFoundError if no tuples returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        subject.delete_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise NotFoundError
        end
        record.wont_be :deleted?
        record.age.must_equal 37
      end

      it 'raises TooManyResultsError if more than one tuple returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        subject.delete_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise TooManyResultsError
        end
        record.wont_be :deleted?
        record.age.must_equal 37
      end

    end

    describe '#delete_many process' do
      it { skip 'needs to be implemented' }
    end

  end
end
