require 'spec_helper'

module Norm
  module Attribute
    describe Character do

      describe 'loading' do
        subject { Character }

        it 'calls to_s on objects' do
          subject.load(4).must_equal '4'
        end

        it 'truncates incoming objects to size (default 1)' do
          subject.load('hello!').must_equal 'h'
        end

        it 'pads undersized strings to the required size' do
          subject.load('hello!', 10).must_equal 'hello!    '
        end

      end

      describe 'loaded object' do
        subject { Character.load('1') }

        it 'casts to string' do
          subject.to_s.must_equal '1'
        end

      end

      describe 'Character()' do

        it 'returns a Loader' do
          Attribute::Character().must_be_kind_of Loader
        end

        it 'loads using Character with the passed in parameters' do
          Attribute::Character(10).load('hello!').must_equal(
            Character.load('hello!', 10)
          )
        end

      end

    end
  end
end
