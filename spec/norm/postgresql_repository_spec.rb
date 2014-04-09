require 'spec_helper'

module Norm
  describe PostgreSQLRepository do

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
      }.new
    }

    describe '#insert_records' do

      it 'sets attributes on records from an enum in same order' do
        tuples, people = [], []
        (1..3).each do |id|
          people << person_record_class.new(
            :name => "Person #{id}", :age => 35 + id
          )
          tuples << {
            'id' => id.to_s, 'name' => "Person #{id}", 'age' => "#{35 + id}",
            'created_at' => Attr::Timestamp.now.to_s,
            'updated_at' => Attr::Timestamp.now.to_s
          }
        end
        subject.insert_records(tuples, people)
        people.each { |person| person.must_be :stored? }
        people.map(&:name).must_equal ['Person 1', 'Person 2', 'Person 3']
        people.map(&:created_at).each { |ts|
          ts.must_be_kind_of Attr::Timestamp
        }
      end

    end

    describe '#all' do

      it 'retrieves all records' do
      end

    end

    describe '#fetch' do

      it 'fetches a record by primary key' do
      end

    end

    describe '#insert' do

      it 'inserts records' do
      end

    end

    describe '#update' do

      it 'updates records' do
      end

    end

    describe '#store' do

      it 'updates or inserts records as necessary' do
      end

    end

    describe '#delete' do

      it 'deletes records' do
      end

    end

  end
end
