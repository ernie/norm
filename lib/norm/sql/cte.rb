module Norm
  module SQL
    class CTE
      attr_reader :table, :statement, :columns

      def initialize(table, statement, columns: [])
        @table     = Attribute::Identifier(table)
        @statement = statement
        @columns   = columns.map { |c| Attribute::Identifier(c) }
      end

      def params
        @statement.params
      end

      def sql
        if @columns.empty?
          "#{@table} AS (#{@statement.sql})"
        else
          "#{@table}(#{@columns.join(', ')}) AS (#{@statement.sql})"
        end
      end

    end
  end
end
