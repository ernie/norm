module Norm
  module Repository

    def self.extended(mod)
      mod.send :include, InstanceMethods
    end

    def record_class=(klass)
      define_method(:record_class) { klass }
    end

    def primary_keys=(attrs)
      keys = Array(attrs).map(&:to_s)
      define_method(:primary_keys) { keys }
    end

    def table_name=(name)
      define_method(:table_name) { name }
    end

    module InstanceMethods

      def read_connection
        'default'
      end

      def write_connection
        'default'
      end

      def record_class
        raise 'zomg' # TODO: real error
      end

      def table_name
        raise 'zomg' # TODO: real error
      end

      def primary_keys
        ['id']
      end

      def fetch(*args)
        exec_select(fetch_statement(*args)).first
      end

      def insert(record)
        exec_insert(insert_statement(record), [record]).first
      end

      def update(record)
        exec_update(update_statement(record), [record]).first
      end

      def exec_select(statement)
        Norm.with_connection(read_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            result.map { |tuple| record_class.new_from_db(tuple) }
          end
        end
      end

      def exec_insert(statement, records)
        Norm.with_connection(write_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            result.each { |tuple|
              records.select { |record|
                record.object_id == tuple['_object_id'].to_i
              }.each { |record|
                record.reset_attributes!(tuple)
                record.stored!
              }
            }
          end
        end
        records
      end

      def exec_update(statement, records)
        Norm.with_connection(write_connection) do |conn|
          conn.exec_statement(statement) do |result, conn|
            result.each { |tuple|
              puts tuple.inspect
              records.select { |record|
                record.object_id == tuple['_object_id'].to_i
              }.each { |record|
                record.reset_attributes!(tuple)
                record.stored!
              }
            }
          end
        end
        records
      end

      def exec_delete(statement)
      end

      def fetch_sql
        <<-SQL
          select * from #{table_name}
          where #{primary_keys.map { |k| "#{k} = %{#{k}}" }.join(' AND ')}
          limit 1
        SQL
      end

      def fetch_statement(*args)
        Statement.select(fetch_sql, Hash[primary_keys.zip(args)])
      end

      def insert_sql
        <<-SQL
          insert into #{table_name} (&{param_keys}) values (&{param_values})
          returning *, %{_object_id}::bigint as _object_id
        SQL
      end

      def insert_statement(record)
        Statement.insert(
          insert_sql,
          record.initialized_attributes.merge('_object_id' => record.object_id)
        )
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
          record.updated_attributes.merge('_object_id' => record.object_id)
        )
      end

    end

  end

end
