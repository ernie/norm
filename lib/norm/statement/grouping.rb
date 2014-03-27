module Norm
  module Statement
    class Grouping < BasicObject

      def initialize(fragment)
        @fragment = fragment
      end

      def sql
        "(#{@fragment.sql})"
      end

      def params
        @fragment.params
      end

      def respond_to_missing?(id, include_private = false)
        super || @fragment.respond_to?(id, include_private)
      end

      def method_missing(id, *args, &block)
        if @fragment.respond_to?(id)
          @fragment.public_send(id, *args, &block)
        else
          super
        end
      end

    end
  end
end
