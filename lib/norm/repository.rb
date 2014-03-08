module Norm
  module Repository

    def self.extended(mod)
      mod.send :include, InstanceMethods
    end

    def primary_keys=(attrs)
      keys = Array(attrs).map(&:to_s)
      define_method(:primary_keys) { keys }
    end

    def table_name=(name)
      define_method(:table_name) { name }
    end

    module InstanceMethods

      attr_accessor :record_class

      def read_connection
        'master'
      end

      def write_connection
        'master'
      end

      def table_name
        raise 'zomg' # TODO: real error
      end

      def primary_keys
        ['id']
      end

      def attribute_names
        record_class.attribute_names
      end

      def fetch(*args)
        exec_select(
          Statement.select('*').
                    from(table_name).
                    where(Hash[primary_keys.zip(args)])
        ).first
      end

      def store(record)
        record.stored? ? update(record) : insert(record)
      end

      def insert(records)
        exec_insert(
          Statement.insert(
            table_name, attribute_names, records
          ), records
        )
      end

      def update(record)
        return record unless record.updated_attributes.any?

        exec_update_one(
          Statement::UpdateOneByPrimaryKeys.new(
            table_name, primary_keys, record
          ), record
        )
      end

      def exec_select(statement)
        Norm.with_connection(read_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            result.map { |tuple| record_class.from_repo(tuple) }
          end
        end
      end

      def exec_insert(statement, records)
        records = Array(records)
        Norm.with_connection(write_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            records.zip(result.to_a).each do |record, tuple|
              record.reset_attributes!(tuple)
              record.stored!
            end
          end
        end
        records
      end

      def exec_update_one(statement, record)
        Norm.with_connection(write_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            tuple = result.first
            record.reset_attributes!(tuple) if tuple
          end
        end
        record
      end

      def exec_delete(statement)
      end

      def update_sql
        <<-SQL
          update #{table_name} set &{param_sets}
          where #{primary_keys.map { |k| "#{k} = %{#{k}}" }.join(' AND ')}
          returning *, %{_object_id}::bigint as _object_id
        SQL
      end

      def update_statement(record)
        Statement.update(
          update_sql,
          record.updated_attributes.merge(
            '_object_id' => record.object_id,
            'updated_at' => 'now()'
          ).merge(Hash[primary_keys.map { |k| [k, record.send(k)] }])
        )
      end

    end

  end

end
