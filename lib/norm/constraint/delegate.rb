module Norm
  module Constraint
    class Delegate

      def constraint_error(error)
        nil
      end

    end
  end
end

require 'norm/constraint/raise_delegate'
require 'norm/constraint/add_errors_delegate'
