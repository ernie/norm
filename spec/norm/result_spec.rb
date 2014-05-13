require 'spec_helper'

module Norm
  describe Result do

    subject { Result }

    it 'requires a success value on initialize' do
      proc { subject.new }.must_raise ArgumentError
      subject.new(true).must_be_kind_of Result
    end

    it 'allows setting the value' do
      result = subject.new(true, 'zomg')
      result.value.must_equal 'zomg'
    end

    it 'is a copy of a Result if one is received as a value' do
      result1 = subject.new(false, 'zomg')
      result2 = subject.new(true, result1)
      result2.must_be :error?
      result2.value.must_equal 'zomg'
    end

    describe '#success?' do

      it 'reflects the value it was instantiated with' do
        subject.new(true).must_be :success?
        subject.new(false).wont_be :success?
      end

    end

    describe '#error?' do

      it 'reflects the complement of its success value' do
        subject.new(false).must_be :error?
        subject.new(true).wont_be :error?
      end

    end

  end
end
