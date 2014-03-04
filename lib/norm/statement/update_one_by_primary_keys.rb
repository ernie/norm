module Norm
  module Statement
    class UpdateOneByPrimaryKeys
      attr_reader :sql, :params, :result_format

      def initialize(table_name, primary_keys, record)
        @table_name, @primary_keys, @record = table_name, primary_keys, record
        @params = []
        @result_format = 0
        compile!
      end

      def compile!
        @sql = <<-SQL
          update #{table_identifier} set #{new_value_sets}
          where #{primary_key_wheres}
          returning #{table_identifier}.*
        SQL
      end

      def counter
        @counter ||= (1..65536).to_enum
      end

      def primary_key_wheres
        make_equalities(@record.read_attributes(@primary_keys)).join(' AND ')
      end

      def attr_identifiers
        @attribute_names.map { |n| make_identifier(n) }.join(', ')
      end

      def new_value_sets
        make_equalities(@record.updated_attributes.merge(default_updates)).
          join(', ')
      end

      def default_updates
        @record.attribute?(:updated_at) ? {'updated_at' => 'now()'} : {}
      end

      def make_equalities(hash)
        hash.map { |k, v|
          @params << v
          "#{make_identifier(k)} = $#{counter.next}"
        }
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
