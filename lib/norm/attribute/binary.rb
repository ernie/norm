module Norm
  module Attribute
    class Binary
      extend Loading

      PG_HEX_BYTEA = /\A\\x[[:xdigit:]]+\z/

      attr_reader :data

      def initialize(stringable)
        @data = Binary === stringable ? stringable.to_str : stringable.to_s
        if PG_HEX_BYTEA === @data
          @data = PG::Connection.unescape_bytea @data
        end
      end

      def to_str
        @data.dup
      end

      def to_s
        '\x'.tap { |out|
          @data.each_byte { |byte| out << byte.to_s(16) }
        }
      end

      class << self

        private

        def load_Object(object, *args)
          Binary.new(object)
        end

      end

    end

    def self.Binary(*)
      Binary
    end

  end
end
