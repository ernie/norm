module Norm
  module SQL
    class Alias < BasicObject
      attr_reader :fragment, :name

      def initialize(fragment, name)
        @fragment = fragment
        @name     = Attribute::Identifier(name)
      end

      def as(name)
        Alias.new(fragment, name)
      end

      def sql
        "#{@fragment.sql} AS #{@name}"
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
