module Norm
  module Constraint
    class Rule

      def initialize(to: nil, **attrs)
        validate_params!(to, attrs)
        @to, @attrs = to, attrs
      end

      def each(&block)
        @to.each(&block)
      end

      def ===(constraint_error)
        @attrs.all? { |name, value|
          value === constraint_error.public_send(name)
        }
      end

      private

      def validate_params!(to, attrs)
        raise ArgumentError, 'A to: parameter is required' unless to
        if attrs.empty?
          raise ArgumentError, 'At least one attribute to match is required'
        end
      end

    end
  end
end
