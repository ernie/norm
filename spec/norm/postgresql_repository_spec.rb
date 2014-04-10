require 'spec_helper'

module Norm
  describe MemoryRepository do

    let(:person_record_class) {
      Class.new(Record) do
        attribute :id,          Attr::Integer
        attribute :name,        Attr::String
        attribute :age,         Attr::Integer
        attribute :created_at,  Attr::Timestamp
        attribute :updated_at,  Attr::Timestamp
      end
    }
    subject {
      record_class = person_record_class
      Class.new(PostgreSQLRepository) {
        self.record_class = record_class

        def all_statement
          Norm::Statement.select.from('people')
        end

        def insert_statement(records)
          columns = record_class.attribute_names
          statement = Norm::Statement.insert("people (#{columns.join(', ')})")
          records.inject(statement) { |stmt, record|
            attrs = record.initialized_attributes
            sql = columns.map { |name| attrs.key?(name) ? '$?' : 'DEFAULT' }.
              join(', ')
            params = (columns & attrs.keys).map { |name| attrs[name] }
            statement.values_sql!(sql, *params)
          }
        end
      }.new
    }

    before {
      Norm.with_connection do |conn|
        conn.exec_string('truncate table people restart identity')
      end
    }

    describe '#all' do

      it 'returns a list of all records in the store' do
        subject.all.must_equal []
        subject.store(person_record_class.new(:name => 'Ernie', :age => 36))
        subject.all.size.must_equal 1
        subject.all.first.must_be_kind_of person_record_class
      end

    end

    describe '#insert' do

      it 'inserts a new record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        records = subject.all
        puts records.inspect
        records.size.must_equal 1
        person = records.first
        person.id.must_equal 1
        person.name.must_equal 'Ernie'
        person.age.must_equal 36
        person.created_at.must_be_kind_of Attr::Timestamp
        person.updated_at.must_be_kind_of Attr::Timestamp
      end

      it 'raises InvalidKeyError if the record has a nil value in its key' do
        person = person_record_class.new(:id => nil, :name => 'Ernie')
        proc { subject.insert(person) }.must_raise(
          Repository::InvalidKeyError
        )
      end

      it 'raises DuplicateKeyError if a record with that key already exists' do
        person1 = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person1)
        person2 = person_record_class.new(:id => person1.id, :name => 'Bert')
        proc { subject.insert(person2) }.must_raise(
          Repository::DuplicateKeyError
        )
      end

    end

    describe '#update' do

      it 'updates a stored record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.name = 'Bert'
        previous_updated_at = person.updated_at
        subject.update(person)
        person = subject.fetch(person.id)
        person.name.must_equal 'Bert'
        person.updated_at.must_be :>, previous_updated_at
      end

      it 'raises InvalidKeyError if the record has a nil value in its key' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person.id = nil
        proc { subject.update(person) }.must_raise(
          Repository::InvalidKeyError
        )
      end

      it 'raises NotFoundError if the record being updated is not present' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person.id = 42
        proc { subject.update(person) }.must_raise(
          Repository::NotFoundError
        )
      end

    end

    describe '#fetch' do

      it 'fetches a stored record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.store(person)
        person = subject.fetch(person.id)
        person.name.must_equal 'Ernie'
        person.age.must_equal 36
        person.created_at.must_be_kind_of Attr::Timestamp
        person.updated_at.must_be_kind_of Attr::Timestamp
      end

    end

    describe '#delete' do

      it 'deletes a stored record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.store(person)
        person = subject.fetch(person.id)
        subject.delete(person)
        subject.fetch(person.id).must_be_nil
        person.must_be :deleted?
        person.wont_be :stored?
      end

    end

    describe '#store' do

      it 'updates and inserts records as appropriate' do
        person1 = person_record_class.new(:name => 'Ernie', :age => 36)
        person2 = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(person1)
        previous_updated_at = person1.updated_at
        subject.store([person1, person2])
        person1.updated_at.must_be :>, previous_updated_at
        person2.must_be :stored?
      end

    end

  end
end
