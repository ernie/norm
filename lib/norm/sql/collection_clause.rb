module Norm
  module SQL
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

require 'norm/sql/select_clause'
require 'norm/sql/from_clause'
require 'norm/sql/where_clause'
require 'norm/sql/group_clause'
require 'norm/sql/having_clause'
require 'norm/sql/order_clause'
require 'norm/sql/values_clause'
require 'norm/sql/set_clause'
require 'norm/sql/using_clause'
