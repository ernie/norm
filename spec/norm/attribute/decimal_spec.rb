require 'spec_helper'

module Norm
  module Attribute
    describe Decimal do

      describe 'loading' do
        subject { Decimal }

        it 'loads integers' do
          subject.load(42).must_equal 42
        end

        it 'loads floats' do
          subject.load(42.0).must_equal 42.0
        end

        it 'loads strings' do
          subject.load('42').must_equal 42
        end

        it 'rounds to specified scale' do
          subject.load('99.999', 10, 2).must_equal 100
        end

      end

      describe 'loaded object' do
        subject { Decimal.load(42) }

        it 'casts to string' do
          if ENV['INTEGRATION'] # FREEDOM PATCHING, AMIRITE?
            subject.to_s.must_equal '42.0'
            subject._original_to_s.must_equal '0.42E2'
          else
            subject.to_s.must_equal '0.42E2'
          end
        end
      end

      describe 'Decimal()' do

        it 'returns a Delegator' do
          Attribute::Decimal().must_be_kind_of Delegator
        end

        it 'loads using Decimal with the passed in parameters' do
          Attribute::Decimal(10, 2).load('3.141592654').must_equal(
            Decimal.load('3.141592654', 10, 2)
          )
        end

      end

    end
  end
end
