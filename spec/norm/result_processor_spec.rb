require 'spec_helper'

module Norm
  describe ResultProcessor do
    subject { ResultProcessor }

    it 'requires a record class to initialize' do
      proc { subject.new }.must_raise ArgumentError
      subject.new(Class.new(Record)).must_be_kind_of ResultProcessor
    end

    describe '#record_class' do

      it 'exposes the initialized record class' do
        klass = Class.new(Record)
        subject.new(klass).record_class.must_be_same_as klass
      end

    end

    describe 'abstract methods' do
      subject { ResultProcessor.new(Class.new(Record)) }

      it 'expects subclasses to implement #select_one' do
        proc { subject.select_one }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #select_many' do
        proc { subject.select_many }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #insert_one' do
        proc { subject.insert_one(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #insert_many' do
        proc { subject.insert_many(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #noop_one' do
        proc { subject.noop_one(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #noop_many' do
        proc { subject.noop_many(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #update_one' do
        proc { subject.update_one(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #update_many' do
        proc { subject.update_many(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #delete_one' do
        proc { subject.delete_one(nil) }.must_raise NotImplementedError
      end

      it 'expects subclasses to implement #delete_many' do
        proc { subject.delete_many(nil) }.must_raise NotImplementedError
      end

    end

  end
end
