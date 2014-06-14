module Norm
  module Constraint
    class RaiseDelegate < Delegate

      def constraint_error(error)
        raise error
      end

    end
  end
end
