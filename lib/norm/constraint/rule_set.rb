module Norm
  module Constraint
    class RuleSet

      def initialize
        @rules = []
      end

      def map(**attrs)
        @rules << Rule.new(attrs)
      end

      def match(error)
        @rules.detect { |rule| rule === error }
      end

    end
  end
end
