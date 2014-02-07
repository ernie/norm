require 'spec_helper'
require 'bigdecimal'

module Norm
  module Attribute
    describe Integer do

      describe 'loading' do
        subject { Integer }

        it 'loads integers' do
          subject.load(42).must_equal 42
        end

        it 'loads strings' do
          subject.load('42').must_equal 42
        end

        it 'loads bigdecimals' do
          subject.load(BigDecimal.new('42.1')).must_equal 42
        end

        it 'loads floats' do
          subject.load(42.1).must_equal 42
        end
      end

      describe 'loaded object' do
        subject { Integer.load(42) }

        it 'casts to string' do
          subject.to_s.must_equal '42'
        end
      end

    end
  end
end
