require 'spec_helper'

module Norm
  describe RecordWrapper do

    let(:record_class) {
      Class.new(Record) {
        attribute :id,   Attr::Integer
        attribute :name, Attr::String
      }
    }

    let(:wrapper_class) {
      Class.new {
        attr_reader :record, :args
        def initialize(record, *args)
          @record, @args = record, args
        end

        def respond_to_missing?(method_id, include_private = false)
          @record.respond_to?(method_id, include_private) or super
        end

        def method_missing(method_id, *args, &block)
          if @record.respond_to?(method_id)
            @record.send(method_id, *args, &block)
          else
            super
          end
        end
      }
    }

    subject { RecordWrapper.new(record_class, wrapper_class, 1, 2, 3) }

    describe 'record class delegation' do

      it 'loads attributes via the record class' do
        subject.load_attribute(:id, '1').must_equal 1
      end

      it 'returns a wrapped record via new' do
        wrapped = subject.new(:id => 1, :name => 'Ernie')
        wrapped.must_be_kind_of wrapper_class
        wrapped.record.must_be_kind_of record_class
        wrapped.args.must_equal [1, 2, 3]
      end

      it 'returns a wrapped and stored record via from_repo' do
        wrapped = subject.from_repo(:id => 1, :name => 'Ernie')
        wrapped.must_be_kind_of wrapper_class
        wrapped.record.must_be_kind_of record_class
        wrapped.args.must_equal [1, 2, 3]
        wrapped.must_be :stored?
      end

    end

  end
end
