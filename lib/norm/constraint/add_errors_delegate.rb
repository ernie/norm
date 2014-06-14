module Norm
  module Constraint
    class AddErrorsDelegate < Delegate

      def initialize(errors, ruleset)
        @errors, @ruleset = errors, ruleset
      end

      def constraint_error(error)
        if rule = @ruleset.match(error)
          rule.each do |attr, message|
            @errors.add(attr, message)
          end
        end
      end

    end
  end
end
