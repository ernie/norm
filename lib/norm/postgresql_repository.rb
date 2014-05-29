module Norm
  class PostgreSQLRepository < Repository

    def all
      select_records(select_statement)
    end

    def fetch(*keys)
      attributes = load_attributes(Hash[primary_keys.zip(keys)])
      select_records(select_statement.where(attributes)).first
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def insert(record)
      Result.capture(ConstraintError) do
        atomically_on(writer) do
          insert_record(
            insert_statement.values(
              *record.attribute_values_at(*attribute_names, default: true)
            ),
            record
          )
        end
      end
    end

    def update(record)
      Result.capture(ConstraintError) do
        if record.updated_attributes?
          atomically_on(writer) do
            update_record(
              scope_to_record(
                update_statement.set(record.updated_attributes(default: true)),
                record
              ),
              record
            )
          end
        end
      end
    end

    def delete(record)
      Result.capture(ConstraintError) do
        atomically_on(writer) do
          delete_record(scope_to_record(delete_statement, record), record)
        end
      end
    end

    def select_statement
      raise NotImplementedError, 'Subclasses must implement #select_statement'
    end

    def insert_statement
      raise NotImplementedError, 'Subclasses must implement #insert_statement'
    end

    def update_statement
      raise NotImplementedError, 'Subclasses must implement #update_statement'
    end

    def delete_statement
      raise NotImplementedError, 'Subclasses must implement #delete_statement'
    end

    private

    def select_records(statement)
      with_connection(reader) do |conn|
        conn.exec_statement(statement) do |result|
          result.map { |tuple| record_class.from_repo(tuple) }
        end
      end
    end

    def insert_record(statement, record)
      exec_for_record(writer, statement, record) do |record|
        record.inserted!
      end
    end

    def update_record(statement, record)
      exec_for_record(writer, statement, record) do |record|
        record.updated!
      end
    end

    def delete_record(statement, record)
      exec_for_record(writer, statement, record) do |record|
        record.deleted!
      end
    end

    def exec_for_record(connection_name, statement, record, &block)
      with_connection(connection_name) do |conn|
        conn.exec_statement(statement) do |result|
          if tuple = result.first
            record.set_attributes(tuple)
            yield record
          end
        end
      end
    end

    def scope_to_record(statement, record)
      statement.where(record.get_original_attributes(*primary_keys))
    end

  end
end
