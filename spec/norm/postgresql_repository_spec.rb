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

      it 'returns a successful result on success' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        result = subject.insert(person)
        result.must_be :success?
      end

      it 'returns an unsuccessful result on constraint error' do
        person = person_record_class.new(
          :id => nil, :name => 'Ernie', :age => 36
        )
        result = subject.insert(person)
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
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

      it 'returns a successful result on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        result = subject.mass_insert([ernie, bert])
        result.must_be :success?
      end

      it 'returns an unsuccessful result on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        duplicate = person_record_class.new(:name => 'Ernie', :age => 36)
        result = subject.mass_insert([ernie, duplicate])
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
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
        result = subject.update(person)
        result.must_be :success?
        person = subject.fetch(person.id)
        person.age.must_be :zero?
        person.updated_at.must_be :>, previous_updated_at
      end

      it 'returns a successful result on success' do
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(person)
        person = subject.fetch(person.id)
        person.name = 'Bert'
        previous_updated_at = person.updated_at
        result = subject.update(person)
        result.must_be :success?
      end

      it 'returns an unsuccessful result on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie.name = 'Bert'
        result = subject.update(ernie)
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
      end

      it 'does nothing if the record has not been updated' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        updated_at = ernie.updated_at
        subject.update(ernie)
        ernie.updated_at.must_equal updated_at
      end

      it 'returns a successful result if no update was needed' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        updated_at = ernie.updated_at
        result = subject.update(ernie)
        result.must_be :success?
      end

    end

    describe '#mass_update' do

      it 'sets updated attributes on passed-in records' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.name, bert.name = 'Ernest', 'Herbert'
        subject.mass_update([ernie, bert])
        ernie.updated_at.must_be :>, ernie_updated
        bert.updated_at.must_be :>, bert_updated
        ernie.name.must_equal 'Ernest'
        bert.name.must_equal 'Herbert'
      end

      it 'allows setting attributes to DEFAULT' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.age, bert.age = Attribute::DEFAULT, Attribute::DEFAULT
        result = subject.mass_update([ernie, bert])
        result.must_be :success?
        ernie.updated_at.must_be :>, ernie_updated
        bert.updated_at.must_be :>, bert_updated
        ernie.age.must_be :zero?
        bert.age.must_be :zero?
      end

      it 'returns a successful result on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.name, bert.name = 'Ernest', 'Herbert'
        result = subject.mass_update([ernie, bert])
        result.must_be :success?
      end

      it 'returns an unsuccessful result on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        ernie.name, bert.name = bert.name, ernie.name
        result = subject.mass_update([ernie, bert])
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
      end

      it 'allows updating multiple primary keys' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert  = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        ernie_updated = ernie.updated_at
        bert_updated  = bert.updated_at
        new_ernie = ernie.id += 2
        new_bert  = bert.id += 2
        result = subject.mass_update([ernie, bert])
        ernie = subject.fetch(new_ernie)
        bert  = subject.fetch(new_bert)
        ernie.updated_at.must_be :>, ernie_updated
        bert.updated_at.must_be :>, bert_updated
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

      it 'returns a successful result on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        result = subject.delete(ernie)
        result.must_be :success?
      end

      it 'returns unsuccessful result on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        post = post_record_class.new(
          :person_id => ernie.id, :title => 'zomg', :body => 'zomg'
        )
        post_repo.insert(post)
        result = subject.delete(ernie)
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
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

      it 'returns a successful result on success' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        result = subject.mass_delete([ernie, bert])
        result.must_be :success?
      end

      it 'returns unsuccessful result on constraint error' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        bert = person_record_class.new(:name => 'Bert', :age => 37)
        subject.mass_insert([ernie, bert])
        post = post_record_class.new(
          :person_id => ernie.id, :title => 'zomg', :body => 'zomg'
        )
        post_repo.insert(post)
        result = subject.mass_delete([ernie, bert])
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
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

      it 'returns a successful result on successful insert' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        result = subject.store(ernie)
        result.must_be :success?
      end

      it 'returns successful result on successful update' do
        ernie = person_record_class.new(:name => 'Ernie', :age => 36)
        subject.insert(ernie)
        ernie.age = 37
        result = subject.store(ernie)
        result.must_be :success?
      end

      it 'returns unsuccessful result on constraint error' do
        ernie = person_record_class.new(
          :id => nil, :name => 'Ernie', :age => 36
        )
        subject.insert(ernie)
        ernie.age = 37
        result = subject.store(ernie)
        result.must_be :error?
        result.value.must_be_kind_of ConstraintError
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

  end
end
