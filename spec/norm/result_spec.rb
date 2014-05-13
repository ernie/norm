require 'spec_helper'

module Norm
  describe Result do

    subject { Result }

    it 'requires a success value on initialize' do
      proc { Result.new }.must_raise ArgumentError
      Result.new(true).must_be_kind_of Result
    end

    it 'allows setting the error' do
      result = Result.new(false, 'zomg')
      result.error.must_equal 'zomg'
    end

    describe '#success?' do

      it 'reflects the value it was instantiated with' do
        subject.new(true).must_be :success?
        subject.new(false).wont_be :success?
      end

    end

  end
end
