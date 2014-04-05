module Norm
  module Statement
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

require 'norm/statement/limit_clause'
require 'norm/statement/offset_clause'
require 'norm/statement/insert_clause'
require 'norm/statement/update_clause'
require 'norm/statement/delete_clause'
require 'norm/statement/returning_clause'
