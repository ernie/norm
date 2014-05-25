require 'spec_helper'

module Norm
  module Attribute
    describe Loading do
      let(:extender) { Class.new {
        extend Loading

        def self.load_Numeric(object, *args)
          'load_Numeric'
        end
      } }

      let(:subclass) { Class.new(extender) {
        def self.load_Integer(object, *args)
          'load_Integer'
        end
      } }

      let(:subclass_of_subclass) { Class.new(subclass) {
        def self.load_Fixnum(object, *args)
          'load_Fixnum'
        end
      } }

      describe 'extension' do
        subject { extender }

        it 'dispatches to a load method for an ancestor if necessary' do
          subject.load(42).must_equal 'load_Numeric'
        end

        it 'loads nil as nil' do
          subject.load(nil).must_equal nil
        end

        it 'loads DEFAULT as DEFAULT' do
          subject.load(Attribute::DEFAULT).must_equal Attribute::DEFAULT
        end

        it 'caches method dispatch information for subsequent calls' do
          subject.load(42)
          subject.instance_variable_get(:@dispatch)[Fixnum].must_equal(
            'load_Numeric'
          )
        end

        it 'allows reset of method dispatch cache' do
          subject.load(42)
          subject.reset_dispatch!
          subject.instance_variable_get(:@dispatch)[Fixnum].must_equal(
            'load_Fixnum'
          )
        end

        it 'raises NoMethodError if no loader found, with original backtrace' do
          err = proc { subject.load('42') }.must_raise NoMethodError
          err.message.must_equal 'No loader for String'
          file, line = subject.method(:load).source_location
          err.backtrace.first.start_with?("#{file}:#{line + 1}").must_equal true
        end
      end

      describe 'inheritance' do
        before { extender.load(42) }
        subject { subclass }

        it 'gives inheriters their own dispatch cache' do
          subclass.load(42).must_equal 'load_Integer'
          subject.instance_variable_get(:@dispatch).wont_equal(
            extender.instance_variable_get(:@dispatch)
          )
        end

        it 'falls back to ancestor loaders if necessary' do
          subclass.load(42.0).must_equal 'load_Numeric'
        end
      end

      describe 'additional inheritance' do
        before { subclass.load(42) }
        subject { subclass_of_subclass }

        it 'gives inheriters of inheriters their own dispatch cache' do
          subject.load(42).must_equal 'load_Fixnum'
          subject.instance_variable_get(:@dispatch).wont_equal(
            subclass.instance_variable_get(:@dispatch)
          )
        end
      end

    end
  end
end
