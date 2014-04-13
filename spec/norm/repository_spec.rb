require 'spec_helper'

module Norm
  describe Repository do
    subject { Class.new(Repository) }
    let(:record_class) { Class.new(Record) }

    it 'requires a record class be set' do
      proc { subject.new }.must_raise Repository::NoRecordClassError
    end

    it 'allows setting a default record class' do
      subject.default_record_class = record_class
      subject.new.record_class.must_be_same_as record_class
    end

    it 'defaults PKs to the identifying attribute names of the record class' do
      subject.new(record_class).primary_keys.must_equal(
        record_class.identifying_attribute_names
      )
    end

    it 'allows setting an alternate list of primary keys with .primary_keys=' do
      subject.primary_keys = [:name, :age]
      subject.new(record_class).primary_keys.must_equal ['name', 'age']
    end

    it 'allows setting an alternate list of primary keys with .primary_key=' do
      subject.primary_key = :name
      subject.new(record_class).primary_keys.must_equal ['name']
    end

    describe '#load_attributes' do
      subject {
        Class.new(Repository) {
          self.default_record_class = Class.new(Record) {
            attribute :id, Attr::Integer
          }
        }.new
      }

      it 'casts the attributes in a hash' do
        subject.load_attributes('id' => '42').must_equal('id' => 42)
      end

    end

    describe 'storage methods' do
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

      it 'requires subclasses to implement #insert' do
        proc { subject.insert(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #update' do
        proc { subject.update(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #delete' do
        proc { subject.delete(nil) }.must_raise NotImplementedError
      end

    end

  end
end
