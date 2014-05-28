require 'spec_helper'

module Norm
  describe Repository do
    subject { Class.new(Repository) }
    let(:record_class) { Class.new(Record) { attribute :id, Attr::Integer } }

    it 'requires a record class' do
      proc { subject.new }.must_raise ArgumentError
      subject.new(record_class).must_be_kind_of Repository
    end

    it 'defaults PKs to the identifying attribute names of the record class' do
      subject.new(record_class).primary_keys.must_equal(
        record_class.new.identifying_attributes.keys
      )
    end

    it 'defaults attribute names to the attribute names of the record class' do
      subject.new(record_class).attribute_names.must_equal(
        record_class.attribute_names
      )
    end

    describe '#load_attributes' do
      subject {
        record_class = Class.new(Record) { attribute :id, Attr::Integer }
        Class.new(Repository) {
          define_method(:record_class) { record_class }
        }.new(record_class)
      }

      it 'casts the attributes in a hash' do
        subject.load_attributes('id' => '42').must_equal('id' => 42)
      end

    end

    it 'defaults connection manager to Norm.connection_manager' do
      repo = subject.new(record_class)
      repo.connection_manager.must_be_same_as Norm.connection_manager
    end

    it 'allows specifying an alternate connection manager via keyword' do
      mgr = Object.new
      repo = subject.new(record_class, connection_manager: mgr)
      repo.connection_manager.must_be_same_as mgr
    end

    it 'defaults reader and writer database to :primary' do
      repo = subject.new(record_class)
      repo.reader.must_equal :primary
      repo.writer.must_equal :primary
    end

    it 'allows specification of alternate reader and writer via keyword' do
      repo = subject.new(record_class, reader: :zomg, writer: :bbq)
      repo.reader.must_equal :zomg
      repo.writer.must_equal :bbq
    end

    describe '#success!' do

      it 'returns a successful result' do
        result = subject.new(record_class).success!
        result.must_be :success?
      end

    end

    describe 'connection convenience methods' do
      let(:connection_manager) { MiniTest::Mock.new }
      subject {
        Class.new(Repository).new(
          record_class,
          connection_manager: connection_manager
        )
      }

      it 'delegates with_connection to connection manager' do
        connection_manager.expect(:with_connection, nil, [:primary])
        subject.with_connection(:primary) {}
        connection_manager.verify
      end

      it 'defaults a parameterless call to with_connection to reader' do
        repo = Class.new(Repository).new(
          record_class,
          connection_manager: connection_manager, reader: :zomg
        )
        connection_manager.expect(:with_connection, nil, [:zomg])
        repo.with_connection {}
        connection_manager.verify
      end

      it 'delegates with_connections to connection manager' do
        connection_manager.expect(:with_connections, nil, [:one, :two])
        subject.with_connections(:one, :two) {}
        connection_manager.verify
      end

      it 'delegates atomically_on to connection manager' do
        connection_manager.expect(:atomically_on, nil, [:one, :two])
        subject.atomically_on(:one, :two) {}
        connection_manager.verify
      end

    end

    describe 'abstract methods' do
      subject { Class.new(Repository).new(Class.new(Record)) }

      it 'requires subclasses to implement #all' do
        proc { subject.all }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #fetch' do
        proc { subject.fetch 1 }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #store' do
        proc { subject.store(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #mass_store' do
        proc { subject.mass_store(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #insert' do
        proc { subject.insert(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #mass_insert' do
        proc { subject.mass_insert(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #update' do
        proc { subject.update(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #mass_update' do
        proc { subject.mass_update(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #delete' do
        proc { subject.delete(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #mass_delete' do
        proc { subject.mass_delete(nil) }.must_raise NotImplementedError
      end

    end

  end
end
