require 'spec_helper'

module Norm
  module Attribute
    describe String do

      describe 'loading' do
        subject { String }

        it 'calls to_s on objects' do
          subject.load(42).must_equal '42'
        end

        it 'truncates incoming objects to size, if supplied' do
          subject.load(1234567890, 5).must_equal '12345'
        end

        it 'does not pad undersized objects' do
          subject.load(12345, 10).must_equal '12345'
        end

      end

      describe 'loaded object' do
        subject { String.load(12345) }

        it 'casts to string' do
          subject.to_s.must_equal '12345'
        end

      end

      describe 'String()' do

        it 'returns a Loader' do
          Attribute::String().must_be_kind_of Loader
        end

        it 'loads using Character with the passed in parameters' do
          Attribute::String(3).load('1234567890').must_equal(
            String.load('1234567890', 3)
          )
        end

      end

    end
  end
end
