require 'spec_helper'

module Norm
  describe Result do

    subject { Result }

    describe 'class methods' do

      describe '.for' do

        it 'returns the Result if a Result is given' do
          result = SuccessResult.new('zomg!')
          subject.for(result).must_be_same_as result
        end

        it 'returns a SuccessResult with the given value if non-Result given' do
          result = subject.for('zomg!')
          result.must_be_kind_of SuccessResult
          result.value.must_equal 'zomg!'
        end

      end

      describe '.capture' do

        it 'requires a block' do
          proc { subject.capture }.must_raise LocalJumpError
        end

        it 'returns a successful result if block exits cleanly' do
          result = subject.capture { 'zomg!' }
          result.must_be_kind_of SuccessResult
          result.value.must_equal 'zomg!'
        end

        it 'raises an error if the block raises an error' do
          proc { subject.capture { raise 'zomg' } }.must_raise RuntimeError
        end

        it 'returns an ErrorResult if the block raises a captured error' do
          error = StandardError.new('zomg!')
          result = subject.capture(StandardError) { raise error }
          result.must_be_kind_of ErrorResult
          result.value.must_be_same_as error
        end

        it 'returns the existing result if the block returns a Result' do
          result = SuccessResult.new('zomg!')
          subject.capture { result }.must_be_same_as result
        end

      end

    end

    it 'defaults to a nil value' do
      subject.new.value.must_be_nil
    end

    it 'allows setting the value' do
      result = subject.new('zomg')
      result.value.must_equal 'zomg'
    end

    it 'requires subclasses to implement #success?' do
      proc { subject.new.success? }.must_raise NotImplementedError
    end

    describe '#error?' do

      it 'reflects the complement of #success?' do
        result = subject.new
        def result.success?
          true
        end
        result.wont_be :error?
      end

    end

    describe 'array behavior' do

      it 'splats to success and value' do
        result = subject.new('value')
        def result.success?
          true
        end
        success, value = result
        success.must_equal true
        value.must_equal 'value'
      end

    end

  end
end
