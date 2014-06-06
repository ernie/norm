module Norm
  module Attribute
    class Identifier
      attr_reader :value

      def initialize(value)
        @value = if Symbol === value
          PG::Connection.quote_ident(value.to_s)
        else
          quote_parts(value.to_s)
        end
      end

      def to_s
        value
      end

      def inspect
        "#<#{self.class} #{value}>"
      end

      def ==(other)
        !!(self.class <=> other.class) &&
          self.value == other.value
      end

      def eql?(other)
        self.class.eql?(other.class) &&
          self.value.eql?(other.value)
      end

      def hash
        self.class.hash ^ value.hash
      end

      private

      def quote_parts(string)
        string.split('.').
          map { |part| PG::Connection.quote_ident(part) }.join('.')
      end

    end

    def self.Identifier(value)
      if Identifier === value
        value
      else
        Identifier.new(value)
      end
    end

  end
end
