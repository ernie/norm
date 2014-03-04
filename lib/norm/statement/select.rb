module Norm
  module Statement
    class Select
      attr_reader :sql, :params, :result_format

      def initialize(options = {})
        @from, @select, @where = options.values_at(:from, :select, :where)
        @select = @select ? attr_identifiers(Array(@select)) : '*'
        @where = Hash(@where)
        @params = []
        @result_format = 0
        compile!
      end

      def compile!
        @sql = <<-SQL
          select #{@select} from #{table_identifier} #{where_clause}
        SQL
        puts @sql
      end

      def counter
        @counter ||= (1..65536).to_enum
      end

      def attr_identifiers
        @select.map { |n| make_identifier(n) }.join(', ')
      end

      def where_clause
        if @where.any?
          "where #{build_wheres}"
        end
      end

      def build_wheres
        @where.map { |attr, value|
          if value.nil?
            "#{make_identifier(attr)} is null"
          else
            params << value
            "#{make_identifier(attr)} = $#{counter.next}"
          end
        }.join(' AND ')
      end

      def table_identifier
        make_identifier(@from)
      end

      def make_identifier(stringable)
        PG::Connection.quote_ident(stringable.to_s)
      end

    end
  end
end
