module Norm
  module Constraint
    class RuleSet
      attr_reader :rules

      def initialize(rules = [])
        @rules = rules.dup
      end

      def map(**attrs)
        @rules << Rule.new(attrs)
      end

      def match(error)
        @rules.detect { |rule| rule === error }
      end

      def +(other)
        self.class.new(self.rules + other.rules)
      end

    end
  end
end
