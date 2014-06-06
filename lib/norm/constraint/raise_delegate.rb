module Norm
  module Constraint
    class RaiseDelegate

      def constraint_error(error)
        raise error
      end

    end
  end
end
