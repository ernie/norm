require 'spec_helper'

module Norm
  describe Repository do
    subject { Class.new(Repository) }
    let(:record_class) { Class.new(Record) }

    it 'defaults PKs to the identifying attribute names of the record class' do
      subject.new(record_class).primary_keys.must_equal(
        record_class.identifying_attribute_names
      )
    end

    describe '#load_attributes' do
      subject {
        record_class = Class.new(Record) { attribute :id, Attr::Integer }
        Class.new(Repository) {
          define_method(:record_class) { record_class }
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
