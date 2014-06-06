module Norm
  class PostgreSQLRepository < Repository

    def all
      select_many(select_statement)
    end

    def fetch(*keys)
      identifying_record = record_class.with_identifiers(*keys)
      select_one(
        select_statement.where(identifying_record.identifying_attributes)
      )
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def insert(record)
      insert_one(
        insert_statement.values(
          *record.attribute_values_at(*attribute_names, default: true)
        ),
        record
      )
    end

    def update(record)
      update_one(
        scope_to_record(
          update_statement.set(record.updated_attributes(default: true)),
          record
        ),
        record
      )
    end

    def delete(record)
      delete_one(scope_to_record(delete_statement, record), record)
    end

    def select_one(statement, connection: reader, processor: self.processor)
      processor.select_one { |process|
        with_connection(connection) do |conn|
          conn.exec_statement(statement, &process)
        end
      }
    end

    def select_many(statement, connection: reader, processor: self.processor)
      processor.select_many { |process|
        with_connection(connection) do |conn|
          conn.exec_statement(statement, &process)
        end
      }
    end

    def insert_one(statement, record,
                   connection: writer, processor: self.processor)
      processor.insert_one(record) { |process|
        atomically_on(connection) do |conn|
          conn.exec_statement(statement, &process)
        end
      }
    end

    def update_one(statement, record,
                   connection: writer, processor: self.processor)
      processor.update_one(record) { |process|
        atomically_on(connection) do |conn|
          conn.exec_statement(statement, &process)
        end
      }
    end

    def delete_one(statement, record,
                   connection: writer, processor: self.processor)
      processor.delete_one(record) { |process|
        atomically_on(connection) do |conn|
          conn.exec_statement(statement, &process)
        end
      }
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
      statement.where(
        record.get_original_attributes(
          *record_class.identifying_attribute_names
        )
      )
    end

  end
end
