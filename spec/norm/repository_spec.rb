require 'spec_helper'

module Norm
  describe Repository do
    let(:instantiator) { Class.new(Record) }
    subject { Class.new(Repository) }

    it 'requires a record instantiator for initialization' do
      proc { subject.new }.must_raise ArgumentError
      subject.new(instantiator).must_be_kind_of Repository
    end

    it 'defaults to "id" for primary keys' do
      subject.new(instantiator).primary_keys.must_equal ['id']
    end

    it 'allows setting an alternate list of primary keys with .primary_keys' do
      subject.primary_keys :name, :age
      subject.new(instantiator).primary_keys.must_equal ['name', 'age']
    end

    it 'allows setting an alternate list of primary keys with .primary_key' do
      subject.primary_key :name
      subject.new(instantiator).primary_keys.must_equal ['name']
    end

    describe 'storage methods' do
      subject { Class.new(Repository).new(instantiator) }

      it 'requires subclasses to implement #all' do
        proc { subject.all }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #fetch' do
        proc { subject.fetch 1 }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #store' do
        proc { subject.store(nil) }.must_raise NotImplementedError
      end

      it 'requires subclasses to implement #delete' do
        proc { subject.delete(nil) }.must_raise NotImplementedError
      end

    end

  end
end
