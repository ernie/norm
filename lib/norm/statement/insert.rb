module Norm
  module Statement
    class Insert
      attr_reader :sql, :params, :result_format

      def initialize(table_name, attribute_names, records)
        @table_name, @attribute_names, @records =
          table_name, attribute_names, Array(records)
        @params = []
        @result_format = 0
        compile!
      end

      def compile!
        @sql = <<-SQL
          insert into #{table_identifier} (#{attr_identifiers})
          values #{attr_placeholders}
          returning #{table_identifier}.*
        SQL
      end

      def counter
        @counter ||= (1..65536).to_enum
      end

      def attr_identifiers
        @attribute_names.map { |n| make_identifier(n) }.join(', ')
      end

      def attr_placeholders
        @records.map { |record|
          "(#{record_placeholders(record)})"
        }.join(', ')
      end

      def record_placeholders(record)
        attrs = record.initialized_attributes
        @attribute_names.map { |attr|
          if attrs.has_key?(attr)
            @params << attrs[attr]
            "$#{counter.next}"
          else
            'DEFAULT'
          end
        }.join(', ')
      end

      def table_identifier
        make_identifier(@table_name)
      end

      def make_identifier(stringable)
        PG::Connection.quote_ident(stringable.to_s)
      end

    end
  end
end
