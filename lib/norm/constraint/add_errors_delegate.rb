module Norm
  module Constraint
    class AddErrorsDelegate < Delegate

      def initialize(errors)
        @errors = errors
      end

      def constraint_error(error)
        send("#{error.type}_error", error)
      end

      private

      def check_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def exclusion_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def foreign_key_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def not_null_error(error)
        @errors.add(error.column_name || :base, :blank)
      end

      def restrict_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def unique_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

    end
  end
end
