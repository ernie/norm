module Norm
  module Statement
    class InsertClause

      def initialize(table_name, *column_names)
        @table_name, @column_names = table_name, column_names
      end

      def sql
        "INSERT INTO #{quote_identifier(@table_name)}#{columns_sql}"
      end

      def params
        []
      end

      def empty?
        false
      end

      private

      def columns_sql
        if @column_names.any?
          " (#{@column_names.map { |name| quote_identifier(name) }.join(', ')})"
        end
      end

      def quote_identifier(stringable)
        PG::Connection.quote_ident(stringable.to_s)
      end

    end
  end
end
