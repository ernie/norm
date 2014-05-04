module Norm
  module SQL
    class ValueClause

      def initialize
        @fragment = nil
      end

      def value=(fragment)
        @fragment = fragment
      end

      def empty?
        @fragment.nil?
      end

      def sql
        @fragment.sql
      end

      def params
        @fragment.params
      end

    end
  end
end

require 'norm/sql/limit_clause'
require 'norm/sql/offset_clause'
require 'norm/sql/insert_clause'
require 'norm/sql/update_clause'
require 'norm/sql/delete_clause'
require 'norm/sql/returning_clause'
