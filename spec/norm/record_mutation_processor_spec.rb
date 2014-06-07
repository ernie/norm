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

      it 'raises ResultMismatchError if no tuples returned' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise ResultMismatchError
        end
        record.wont_be :stored?
        record.id.must_be_nil
      end

      it 'raises ResultMismatchError if more than one tuple returned' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise ResultMismatchError
        end
        record.wont_be :stored?
        record.id.must_be_nil
      end

    end

    describe '#insert_many process' do

      it 'updates the passed-in records with the returned tuples in order' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert_many([ernie, bert]) do |process|
          process.call(two_tuples, nil)
        end
        ernie.must_be :stored?
        ernie.id.must_equal 1
        bert.must_be :stored?
        bert.id.must_equal 2
      end

      it 'returns false on constraint error' do
        error = Constraint::ConstraintError.new(PG::Error.new)
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        result = subject.insert_many([ernie, bert]) do |process|
            raise error
          end
        result.must_equal false
      end

      it 'raises ResultMismatchError when unexpected number of results' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        error = proc {
          subject.insert_many([ernie, bert]) do |process|
            process.call(no_tuples, nil)
          end
        }.must_raise ResultMismatchError
        error.message.must_equal '0 results returned, but 2 expected'
      end

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

      it 'raises ResultMismatchError if no tuples returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        record.age = 37
        record.must_be :updated_attributes?
        subject.update_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise ResultMismatchError
        end
        record.must_be :updated_attributes?
        record.age.must_equal 37
      end

      it 'raises ResultMismatchError if more than one tuple returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        record.age = 37
        record.must_be :updated_attributes?
        subject.update_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise ResultMismatchError
        end
        record.must_be :updated_attributes?
        record.age.must_equal 37
      end

    end

    describe '#update_many process' do

      it 'updates the passed-in records with the returned tuples by match' do
        ernie = person_record_class.new(:id => 1, :name => 'Ernie', :age => 35)
        bert = person_record_class.new(:id => 2, :name => 'Bert', :age => 36)
        subject.update_many([bert, ernie]) do |process|
          process.call(two_tuples, nil)
        end
        ernie.wont_be :updated_attributes?
        bert.wont_be :updated_attributes?
        ernie.age.must_equal 36
        bert.age.must_equal 37
      end

      it 'returns false on constraint error' do
        error = Constraint::ConstraintError.new(PG::Error.new)
        ernie = person_record_class.new(:id => 1, :name => 'Ernie', :age => 36)
        bert = person_record_class.new(:id => 2, :name => 'Bert', :age => 37)
        result = subject.update_many([ernie, bert]) do |process|
            raise error
          end
        result.must_equal false
      end

      it 'raises ResultMismatchError when unexpected number of results' do
        ernie = person_record_class.new(:id => 1, :name => 'Ernie', :age => 36)
        bert = person_record_class.new(:id => 2, :name => 'Bert', :age => 37)
        error = proc {
          subject.update_many([ernie, bert]) do |process|
            process.call(no_tuples, nil)
          end
        }.must_raise ResultMismatchError
        error.message.must_equal '0 results returned, but 2 expected'
      end

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

      it 'raises ResultMismatchError if no tuples returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        subject.delete_one(record) do |process|
          proc { process.call(no_tuples, nil) }.must_raise ResultMismatchError
        end
        record.wont_be :deleted?
        record.age.must_equal 37
      end

      it 'raises ResultMismatchError if more than one tuple returned' do
        record = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        subject.delete_one(record) do |process|
          proc { process.call(two_tuples, nil) }.must_raise ResultMismatchError
        end
        record.wont_be :deleted?
        record.age.must_equal 37
      end

    end

    describe '#delete_many process' do

      it 'updates the passed-in records with the returned tuples by match' do
        ernie = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 37
        )
        bert = person_record_class.from_repo(
          :id => 2, :name => 'Bert', :age => 38
        )
        subject.delete_many([bert, ernie]) do |process|
          process.call(two_tuples, nil)
        end
        ernie.must_be :deleted?
        bert.must_be :deleted?
        ernie.age.must_equal 36
        bert.age.must_equal 37
      end

      it 'returns false on constraint error' do
        error = Constraint::ConstraintError.new(PG::Error.new)
        ernie = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        bert = person_record_class.from_repo(
          :id => 2, :name => 'Bert', :age => 37
        )
        result = subject.delete_many([ernie, bert]) do |process|
            raise error
          end
        result.must_equal false
      end

      it 'raises ResultMismatchError if unexpected number of tuples returned' do
        ernie = person_record_class.from_repo(
          :id => 1, :name => 'Ernie', :age => 36
        )
        bert = person_record_class.from_repo(
          :id => 2, :name => 'Bert', :age => 37
        )
        error = proc {
          subject.delete_many([bert, ernie]) do |process|
            process.call(no_tuples, nil)
          end
        }.must_raise ResultMismatchError
        ernie.wont_be :deleted?
        bert.wont_be :deleted?
      end

    end

  end
end
