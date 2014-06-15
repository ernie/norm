require 'spec_helper'

module Norm
  module Constraint
    describe AddErrorsDelegate do
      def mock_errors(*args)
        errors = MiniTest::Mock.new
        errors.expect(:add, nil, args)
      end

      describe 'check constraints' do

        it 'processes constraint name with options' do
          errors = mock_errors(:name, :between, :low => '3', :high => '64')
          delegate = AddErrorsDelegate.new(errors)
          error = Struct.new(:type, :constraint_name).
            new(:check, 'name:between(low:3,high:64)')
          delegate.constraint_error(error)
          errors.verify
        end

        it 'processes constraint name without options' do
          errors = mock_errors(:name, :some_key, {})
          delegate = AddErrorsDelegate.new(errors)
          error = Struct.new(:type, :constraint_name).
            new(:check, 'name:some_key')
          delegate.constraint_error(error)
          errors.verify
        end

      end

    end
  end
end
