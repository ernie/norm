module Norm
  module Statement
    class CollectionClause

      def initialize
        @fragments = []
      end

      def initialize_copy(orig)
        @fragments = @fragments.dup
      end

      def <<(fragment)
        @fragments << fragment
      end

      def empty?
        @fragments.empty?
      end

      def sql
        @fragments.map(&:sql).join(' ')
      end

      def params
        @fragments.map(&:params).inject(&:+)
      end

    end
  end
end

require 'norm/statement/select_clause'
require 'norm/statement/from_clause'
require 'norm/statement/where_clause'
require 'norm/statement/group_clause'
require 'norm/statement/having_clause'
require 'norm/statement/order_clause'
