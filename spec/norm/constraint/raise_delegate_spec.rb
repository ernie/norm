require 'spec_helper'

module Norm
  module Constraint
    describe RaiseDelegate do

      subject { RaiseDelegate.new }

      it 're-raises the error it is sent' do
        error = ConstraintError.new(PG::Error.new)
        raised = proc { subject.constraint_error(error) }.
          must_raise(ConstraintError)
        raised.must_be_same_as error
      end

    end
  end
end
