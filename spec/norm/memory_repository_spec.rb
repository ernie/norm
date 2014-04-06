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
    subject { Class.new(MemoryRepository).new(person_record_class) }

    it 'returns a list of all records in the store' do
      subject.all.must_equal []
    end

    it 'stores a new record' do
      person = person_record_class.new(:name => 'Ernie', :age => 36)
      subject.store(person)
      records = subject.all
      records.size.must_equal 1
      person = records.first
      person.id.must_equal 1
      person.name.must_equal 'Ernie'
      person.age.must_equal 36
      person.created_at.must_be_kind_of Attr::Timestamp
      person.updated_at.must_be_kind_of Attr::Timestamp
    end

    it 'fetches a stored record' do
      person = person_record_class.new(:name => 'Ernie', :age => 36)
      subject.store(person)
      person = subject.fetch(person.id)
      person.name.must_equal 'Ernie'
      person.age.must_equal 36
      person.created_at.must_be_kind_of Attr::Timestamp
      person.updated_at.must_be_kind_of Attr::Timestamp
    end

    it 'updates a stored record' do
      person = person_record_class.new(:name => 'Ernie', :age => 36)
      subject.store(person)
      person = subject.fetch(person.id)
      person.name = 'Bert'
      subject.store(person)
      person = subject.fetch(person.id)
      person.name.must_equal 'Bert'
      person.updated_at.must_be :>, person.created_at
    end

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
end
