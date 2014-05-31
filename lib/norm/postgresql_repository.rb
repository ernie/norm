module Norm
  class PostgreSQLRepository < Repository

    def all
      processor.select_many do |process|
        with_connection(reader) do |conn|
          conn.exec_statement(select_statement, &process)
        end
      end
    end

    def fetch(*keys)
      processor.select_one do |process|
        attributes = load_attributes(Hash[primary_keys.zip(keys)])
        with_connection(reader) do |conn|
          conn.exec_statement(select_statement.where(attributes), &process)
        end
      end
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def insert(record)
      processor.insert_one(record) do |process|
        atomically_on(writer) do |conn|
          conn.exec_statement(
            insert_statement.values(
              *record.attribute_values_at(*attribute_names, default: true)
            ),
            &process
          )
        end
      end
    end

    def update(record)
      processor.update_one(record) do |process|
        atomically_on(writer) do |conn|
          conn.exec_statement(
            scope_to_record(
              update_statement.set(record.updated_attributes(default: true)),
              record
            ),
            &process
          )
        end
      end
    end

    def delete(record)
      processor.delete_one(record) do |process|
        atomically_on(writer) do |conn|
          conn.exec_statement(
            scope_to_record(delete_statement, record), &process
          )
        end
      end
    end

    def select_statement
      raise NotImplementedError,
        "This repository doesn't implement #select_statement"
    end

    def insert_statement
      raise NotImplementedError,
        "This repository doesn't implement #insert_statement"
    end

    def update_statement
      raise NotImplementedError,
        "This repository doesn't implement #update_statement"
    end

    def delete_statement
      raise NotImplementedError,
        "This repository doesn't implement #delete_statement"
    end

    private

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
