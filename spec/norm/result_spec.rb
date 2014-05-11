require 'spec_helper'

module Norm
  describe Result do

    subject { Result }

    it 'requires a success value on initialize' do
      proc { Result.new }.must_raise ArgumentError
      Result.new(true).must_be_kind_of Result
    end

    it 'allows specifying a number of rows affected via keyword' do
      result = Result.new(true, affected_rows: 5)
      result.affected_rows.must_equal 5
    end

    it 'allows specifying a number of rows affected via keyword' do
      result = Result.new(true, affected_rows: 5)
      result.affected_rows.must_equal 5
    end

    it 'allows setting the constraint error via keyword' do
      result = Result.new(false, constraint_error: 'zomg')
      result.constraint_error.must_equal 'zomg'
    end

    describe '#success?' do

      it 'reflects the value it was instantiated with' do
        subject.new(true).must_be :success?
        subject.new(false).wont_be :success?
      end

    end

    describe 'array-like behavior' do

      it 'sets success and error object on multiple assignment' do
        result = Result.new(false, constraint_error: 'zomg')
        success, error = result
        success.must_equal false
        error.must_equal 'zomg'
      end

    end

  end
end
