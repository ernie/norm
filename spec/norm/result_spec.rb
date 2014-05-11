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

    describe 'addition' do

      it 'returns a new result with sum of affected_rows' do
        result1 = Result.new(true, affected_rows: 1)
        result2 = Result.new(true, affected_rows: 1)
        sum = result1 + result2
        sum.affected_rows.must_equal 2
      end

      it 'will not sum an unsuccessful result on right' do
        result1 = Result.new(true, affected_rows: 1)
        result2 = Result.new(false)
        proc { result1 + result2 }.must_raise ArgumentError
      end

      it 'will not sum an unsuccessful result on left' do
        result1 = Result.new(false)
        result2 = Result.new(true, affected_rows: 1)
        proc { result1 + result2 }.must_raise ArgumentError
      end

    end

  end
end
