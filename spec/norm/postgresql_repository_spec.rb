require 'spec_helper'

module Norm
  describe PostgreSQLRepository do

    let(:person_record_class) {
      Class.new(Record) do
        attribute :id,         Attr::Integer
        attribute :name,       Attr::String
        attribute :age,        Attr::Integer
        attribute :created_at, Attr::Timestamp
        attribute :updated_at, Attr::Timestamp
      end
    }

    let(:erroneous_person_record_class) {
      Class.new(Record) do
        attribute :id,         Attr::Integer
        attribute :name,       Attr::String
        attribute :age,        Attr::Integer
        attribute :created_at, Attr::Timestamp
        attribute :updated_at, Attr::Timestamp
        identity  :name
      end
    }

    let(:person_repo) {
      Class.new(PostgreSQLRepository) {
        def select_statement
          Norm::SQL.select.from('people')
        end

        def insert_statement
          Norm::SQL.insert(:people, attribute_names).returning('*')
        end

        def update_statement
          Norm::SQL.update('people').returning('*')
        end

        def delete_statement
          Norm::SQL.delete('people').returning('*')
        end
      }.new(person_record_class)
    }

    let(:post_record_class) {
      Class.new(Record) do
        attribute :id,         Attr::Integer
        attribute :person_id,  Attr::Integer
        attribute :title,      Attr::String
        attribute :body,       Attr::String
        attribute :created_at, Attr::Timestamp
        attribute :updated_at, Attr::Timestamp
      end
    }

    let(:post_repo) {
      Class.new(PostgreSQLRepository) {
        def select_statement
          Norm::SQL.select.from('posts')
        end

        def insert_statement
          Norm::SQL.insert(:posts, attribute_names).returning('*')
        end

        def update_statement
          Norm::SQL.update('posts').returning('*')
        end

        def delete_statement
          Norm::SQL.delete('posts').returning('*')
        end
      }.new(post_record_class)
    }

    let(:user_record_class) {
      Class.new(Record) do
        attribute :username,           Attr::String
        attribute :email,              Attr::String
        attribute :first_name,         Attr::String
        attribute :last_name,          Attr::String
        attribute :encrypted_password, Attr::String
        attribute :created_at,         Attr::Timestamp
        attribute :updated_at,         Attr::Timestamp
        identity :first_name, :last_name
      end
    }

    let(:user_repo) {
      Class.new(PostgreSQLRepository) {
        def select_statement
          Norm::SQL.select.from('users')
        end

        def insert_statement
          Norm::SQL.insert(:users, attribute_names).returning('*')
        end

        def update_statement
          Norm::SQL.update('users').returning('*')
        end

        def delete_statement
          Norm::SQL.delete('users').returning('*')
        end
      }.new(user_record_class)
    }

    let(:erroneous_repo) {
      Class.new(PostgreSQLRepository) {
        def select_statement
          Norm::SQL.select.from('people')
        end

        def insert_statement
          Norm::SQL.insert(:people, attribute_names)
        end

        def update_statement
          Norm::SQL.update('people').returning('*')
        end

        def delete_statement
          Norm::SQL.delete('people').returning('*')
        end
      }.new(erroneous_person_record_class)
    }

    subject { person_repo }

    before {
      subject.with_connection(:primary) do |conn|
        conn.exec_string('truncate table people, posts, users restart identity')
      end
    }

    describe 'abstract methods' do
      subject { Class.new(PostgreSQLRepository).new(person_record_class) }

      it 'requires subclasses implement #select_statement' do
        proc { subject.select_statement }.must_raise NotImplementedError
      end

      it 'requires subclasses implement #insert_statement' do
        proc { subject.insert_statement }.must_raise NotImplementedError
      end

      it 'requires subclasses implement #update_statement' do
        proc { subject.update_statement }.must_raise NotImplementedError
      end

      it 'requires subclasses implement #delete_statement' do
        proc { subject.delete_statement }.must_raise NotImplementedError
      end

    end

    describe 'with a composite primary key' do
      subject { user_repo }

      it 'fetches with all keys' do
        user = user_record_class.new(
          :username => 'ernie', :email => 'ernie@erniemiller.org',
          :first_name => 'Ernie', :last_name => 'Miller',
          :encrypted_password => 'zomg'
        )
        subject.insert(user)
        ernie = subject.fetch 'Ernie', 'Miller'
        ernie.username.must_equal 'ernie'
      end

      it 'deletes with all keys' do
        user = user_record_class.new(
          :username => 'ernie', :email => 'ernie@erniemiller.org',
          :first_name => 'ernie', :last_name => 'miller',
          :encrypted_password => 'zomg'
        )
        subject.insert(user)
        subject.delete(user)
        ernie = subject.fetch 'Ernie', 'Miller'
        ernie.must_be_nil
      end

      it 'updates with all keys' do
        user = user_record_class.new(
          :username => 'ernie', :email => 'ernie@erniemiller.org',
          :first_name => 'ernie', :last_name => 'miller',
          :encrypted_password => 'zomg'
        )
        subject.insert(user)
        user.first_name = 'Ernest'
        user.last_name  = 'Mueller'
        subject.update(user)
        ernie = subject.fetch 'Ernest', 'Mueller'
        ernie.username.must_equal 'ernie'
      end

    end

    describe '#select_one' do

      it 'executes a statement and returns a record' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        record = subject.select_one(Norm::SQL.select.from(:people))
        record.must_equal ernie
      end

    end

    describe '#select_many' do

      it 'executes a statement and returns an array of records' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        subject.insert(bert)
        records = subject.select_many(SQL.select.from(:people))
        records.must_include ernie
        records.must_include bert
      end

    end

    describe '#insert_one' do

      it 'inserts via SQL and modifies the record, returning true on success' do
        record = person_record_class.new
        result = subject.insert_one(
          SQL.insert(:people, [:name, :age]).values('Ernie', 36).returning('*'),
          record
        )
        result.must_equal true
        record.id.must_equal 1
        record.name.must_equal 'Ernie'
        record.age.must_equal 36
      end

      it 'returns false on constraint error' do
        record = person_record_class.new
        result = subject.insert_one(
          SQL.insert(:people, [:name, :age]).values('Ernie', 36).returning('*'),
          record
        )
        result.must_equal true
        result = subject.insert_one(
          SQL.insert(:people, [:id, :name, :age]).
            values(record.id, 'Ernie', 36).returning('*'),
          record
        )
        result.must_equal false
      end

    end

    describe '#insert_many' do

      it 'executes statement and modifies records, returning true on success' do
        records = 2.times.map { person_record_class.new }
        result = subject.insert_many(
          SQL.insert(:people, [:name, :age]).
            values('Ernie', 36).values('Bert', 37).returning('*'),
          records
        )
        result.must_equal true
        ernie, bert = records
        ernie.get_attributes(:id, :name, :age).must_equal(
          :id => 1, :name => 'Ernie', :age => 36
        )
        bert.get_attributes(:id, :name, :age).must_equal(
          :id => 2, :name => 'Bert', :age => 37
        )
      end

      it 're-raises constraint error if encountered' do
        records = 2.times.map { person_record_class.new }
        result = subject.insert_many(
            SQL.insert(:people, [:id, :name, :age]).
              values(nil, 'Ernie', 36).returning('*'),
            records
          )
        result.must_equal false
      end

    end

    describe '#update_one' do

      it 'updates via SQL and modifies the record, returning true on success' do
        record = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(record)
        record.name = 'Just making the processor think I was updated'
        result = subject.update_one(
          SQL.update(:people).set(:age => 37).where(:id => record.id).
            returning('*'),
          record
        )
        result.must_equal true
        record.name.must_equal 'Ernie'
        record.age.must_equal 37
      end

      it 'returns false on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        subject.insert(bert)
        original_id = bert.id
        bert.name = 'Updated name'
        result = subject.update_one(
          SQL.update(:people).set(:id => ernie.id).where(:id => bert.id).
            returning('*'),
          bert
        )
        result.must_equal false
        bert.id.must_equal original_id
      end

    end

    describe '#delete_one' do

      it 'deletes via SQL and modifies the record, returning true on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        result = subject.delete_one(
          SQL.delete(:people).where(:id => ernie.id).returning('*'),
          ernie
        )
        result.must_equal true
        ernie.must_be :deleted?
      end

      it 'returns false on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        post  = post_record_class.new(
          :person_id => ernie.id, :title => 'Title', :body => 'Body'
        )
        post_repo.insert(post)
        result = subject.delete_one(
          SQL.delete(:people).where(:id => ernie.id).returning('*'),
          ernie
        )
        result.must_equal false
        ernie.wont_be :deleted?
      end

    end

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

      it 'returns false on constraint error' do
        person = person_record_class.new(
          :id => nil, :name => 'Ernie', :age => 36
        )
        subject.insert(person).must_equal false
      end

      it 'raises ResultMismatchError if no results are returned' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        proc { erroneous_repo.insert(person) }.must_raise ResultMismatchError
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

      it 'allows updating primary keys' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        new_id = person.id += 1
        previous_updated_at = person.updated_at
        subject.update(person)
        person = subject.fetch(new_id)
        person.wont_be_nil
        person.updated_at.must_be :>, previous_updated_at
      end

      it 'allows setting an attribute to DEFAULT' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.age = Attribute::DEFAULT
        previous_updated_at = person.updated_at
        subject.update(person).must_equal true
        person = subject.fetch(person.id)
        person.age.must_be :zero?
        person.updated_at.must_be :>, previous_updated_at
      end

      it 'allows setting an attribute to an identifier' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.age = Attribute::Identifier('id')
        previous_updated_at = person.updated_at
        subject.update(person).must_equal true
        person = subject.fetch(person.id)
        person.age.must_equal person.id
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

      it 'returns false on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        subject.insert(bert)
        ernie.id = bert.id
        subject.update(ernie).must_equal false
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

      it 'raises ResultMismatchError if no results are returned' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        ernie.stored!
        ernie.age = 37
        proc { erroneous_repo.update(ernie) }.must_raise ResultMismatchError
      end

      it 'raises ResultMismatchError if more than one result is returned' do
        ernie1 = person_record_class.new(:name => 'Ernie', :age => 36)
        ernie2 = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie1)
        subject.insert(ernie2)
        ernie2.age = 37
        proc { erroneous_repo.update(ernie2) }.must_raise ResultMismatchError
      end

    end

    describe '#delete' do

      it 'deletes a stored record' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.insert(ernie)
        subject.insert(bert)
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

      it 'returns false on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        post = post_record_class.new(
          :person_id => ernie.id, :title => 'zomg', :body => 'zomg'
        )
        post_repo.insert(post)
        subject.delete(ernie).must_equal false
      end

      it 'raises ResultMismatchError if no results are returned' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        ernie.stored!
        proc { erroneous_repo.delete(ernie) }.must_raise ResultMismatchError
      end

      it 'raises ResultMismatchError if more than one result is returned' do
        ernie1 = person_record_class.new(:name => 'Ernie', :age => 36)
        ernie2 = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie1)
        subject.insert(ernie2)
        proc { erroneous_repo.delete(ernie2) }.must_raise ResultMismatchError
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

      it 'returns false on constraint error' do
        ernie = person_record_class.new(
          :id => nil, :name => 'Ernie', :age => 36
        )
        subject.insert(ernie)
        ernie.age = 37
        subject.store(ernie).must_equal false
      end

    end

  end
end
