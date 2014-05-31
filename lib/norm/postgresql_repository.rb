module Norm
  class PostgreSQLRepository < Repository

    def all
      with_connection(reader) { |conn| select_records(conn, select_statement) }
    end

    def fetch(*keys)
      attributes = load_attributes(Hash[primary_keys.zip(keys)])
      with_connection(reader) do |conn|
        select_records(conn, select_statement.where(attributes)).first
      end
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def insert(record)
      Result.capture(ConstraintError) do
        atomically_on(writer) do |conn|
          insert_record(
            conn,
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
          atomically_on(writer) do |conn|
            update_record(
              conn,
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
        atomically_on(writer) do |conn|
          delete_record(conn, scope_to_record(delete_statement, record), record)
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

    def select_records(conn, statement)
      conn.exec_statement(statement) do |result|
        result.map { |tuple| record_class.from_repo(tuple) }
      end
    end

    def insert_record(conn, statement, record)
      conn.exec_statement(statement) do |result|
        require_one_result!(result)
        record.set_attributes(result.first) and record.inserted!
      end
    end

    def update_record(conn, statement, record)
      conn.exec_statement(statement) do |result|
        require_one_result!(result)
        tuple = result.first
        record.set_attributes(result.first) and record.updated!
      end
    end

    def delete_record(conn, statement, record)
      conn.exec_statement(statement) do |result|
        require_one_result!(result)
        record.set_attributes(result.first) and record.deleted!
      end
    end

    def scope_to_record(statement, record)
      statement.where(record.get_original_attributes(*primary_keys))
    end

    def require_one_result!(result)
      if result.ntuples < 1
        raise NotFoundError, 'No results for query!'
      elsif result.ntuples > 1
        raise TooManyResultsError,
          "#{result.ntuples} rows returned when only one was expected."
      end
    end

  end
end
