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
      Class.new(PostgreSQLRepository) {
        def select_statement
          Norm::SQL.select.from('people')
        end

        def insert_statement
          column_list = record_class.attribute_names.join(', ')
          Norm::SQL.insert("people (#{column_list})").returning('*')
        end

        def update_statement
          Norm::SQL.update('people').returning('*')
        end

        def delete_statement
          Norm::SQL.delete('people').returning('*')
        end
      }.new(person_record_class)
    }

    before {
      Norm.with_connection do |conn|
        conn.exec_string('truncate table people restart identity')
      end
    }

    describe '#all' do

      it 'returns a list of all records in the store' do
        subject.all.must_equal []
        subject.insert(person_record_class.new(:name => 'Ernie', :age => 36))
        subject.all.size.must_equal 1
        subject.all.first.must_be_kind_of person_record_class
      end

    end

    describe '#fetch' do

      it 'fetches a stored record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.name.must_equal 'Ernie'
        person.age.must_equal 36
        person.created_at.must_be_kind_of Attr::Timestamp
        person.updated_at.must_be_kind_of Attr::Timestamp
      end

    end

    describe '#insert' do

      it 'inserts a new record' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        records = subject.all
        records.size.must_equal 1
        person = records.first
        person.id.must_equal 1
        person.name.must_equal 'Ernie'
        person.age.must_equal 36
        person.created_at.must_be_kind_of Attr::Timestamp
        person.updated_at.must_be_kind_of Attr::Timestamp
      end

      it 'returns true on success' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person).must_equal true
      end

    end

    describe '#mass_insert' do

      it 'inserts multiple records' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        records = subject.all
        records.size.must_equal 2
        ernie = records.detect { |r| r.name == 'Ernie' }
        bert = records.detect { |r| r.name == 'Bert' }
        ernie.age.must_equal 36
        bert.age.must_equal 37
      end

      it 'returns true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert]).must_equal true
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

      it 'returns true on success' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.name = 'Bert'
        previous_updated_at = person.updated_at
        subject.update(person).must_equal true
      end

      it 'does nothing if the record has not been updated' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        updated_at = ernie.updated_at
        subject.update(ernie)
        ernie.updated_at.must_equal updated_at
      end

      it 'returns true if no update was needed' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        updated_at = ernie.updated_at
        subject.update(ernie).must_equal true
      end

    end

    describe '#mass_update' do

      it 'sets updated attributes on passed-in records' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.name, bert.name = bert.name, ernie.name
        subject.mass_update([ernie, bert])
        ernie.updated_at.must_be :>, ernie_updated
        bert.updated_at.must_be :>, bert_updated
        ernie.name.must_equal 'Bert'
        bert.name.must_equal 'Ernie'
      end

      it 'returns true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.name, bert.name = bert.name, ernie.name
        subject.mass_update([ernie, bert]).must_equal true
      end

    end

    describe '#delete' do

      it 'deletes a stored record' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        subject.delete(ernie)
        subject.fetch(ernie.id).must_be_nil
        bert = subject.fetch(bert.id)
        ernie.must_be :deleted?
        ernie.wont_be :stored?
        bert.must_be :stored?
        bert.wont_be :deleted?
      end

      it 'returns true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        subject.delete(ernie).must_equal true
      end

    end

    describe '#mass_delete' do

      it 'deletes multiple stored records' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        subject.mass_delete([ernie, bert])
        subject.fetch(ernie.id).must_be_nil
        subject.fetch(bert.id).must_be_nil
        ernie.must_be :deleted?
        ernie.wont_be :stored?
        bert.must_be :deleted?
        bert.wont_be :stored?
      end

      it 'returns true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        subject.mass_delete([ernie, bert]).must_equal true
      end

    end

    describe '#store' do

      it 'inserts a record if it is not already stored' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.store(ernie)
        subject.fetch(ernie.id).must_equal ernie
        ernie.must_be :stored?
      end

      it 'updates an already-stored record' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        previously_updated_at = ernie.updated_at
        ernie.age = 37
        subject.store(ernie)
        ernie.updated_at.must_be :>, previously_updated_at
      end

      it 'returns true on successful insert' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.store(ernie).must_equal true
      end

      it 'returns true on successful update' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        ernie.age = 37
        subject.store(ernie).must_equal true
      end

    end

    describe '#mass_store' do

      it 'updates or inserts records as appropriate' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        ernie.age = 37
        previous_updated_at = ernie.updated_at
        subject.mass_store([ernie, bert])
        ernie.updated_at.must_be :>, previous_updated_at
        bert.must_be :stored?
      end

      it 'returns true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        ernie.age = 37
        subject.mass_store([ernie, bert]).must_equal true
      end

    end

  end
end
