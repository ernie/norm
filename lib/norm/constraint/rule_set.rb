module Norm
  module Constraint
    class RuleSet
      attr_reader :rules

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
