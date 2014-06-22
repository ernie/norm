module Norm
  class Repository

    attr_reader :record_class, :connection_manager, :processor, :reader, :writer

    def initialize(record_class,
                   connection_manager: Norm.connection_manager,
                   processor: RecordMutationProcessor.new(record_class),
                   reader: :primary, writer: :primary)
      @record_class       = record_class
      @connection_manager = connection_manager
      @processor          = processor
      @reader, @writer    = reader, writer
    end

    def with_connection(name = reader, &block)
      connection_manager.with_connection(name, &block)
    end

    def with_connections(*args, &block)
      connection_manager.with_connections(*args, &block)
    end

    def atomically_on(*args, &block)
      connection_manager.atomically_on(*args, &block)
    end

    def load_attributes(attributes)
      record_class.new(attributes).get_attributes(*attributes.keys)
    end

    def attribute_names
      record_class.attribute_names
    end

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

    def mass_insert(records)
      return processor.noop_many(records) if records.empty?

      insert_many(
        records.reduce(insert_statement) { |statement, record|
          statement.values(
            *record.attribute_values_at(*attribute_names, default: true)
          )
        },
        records
      )
    end

    def update(record)
      return processor.noop_one(record) unless record.updated_attributes?

      update_one(
        scope_to_record(
          update_statement.set(record.updated_attributes(default: true)),
          record
        ),
        record
      )
    end

    def mass_update(records, attributes)
      return processor.noop_many(records) if records.empty? || attributes.empty?

      records.each do |record|
        record.reset_attributes!
        record.set_attributes(attributes)
      end

      update_many(
        scope_to_records(
          update_statement.set(attributes), records
        ),
        records
      )
    end

    def delete(record)
      delete_one(scope_to_record(delete_statement, record), record)
    end

    def mass_delete(records)
      return processor.noop_many(records) if records.empty?

      delete_many(
        scope_to_records(delete_statement, records), records
      )
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

    def insert_many(statement, records,
                    connection: writer, processor: self.processor)
      processor.insert_many(records) { |process|
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

    def update_many(statement, records,
                    connection: writer, processor: self.processor)
      processor.update_many(records) { |process|
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

    def delete_many(statement, records,
                    connection: writer, processor: self.processor)
      processor.delete_many(records) { |process|
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

    def scope_to_records(statement, records)
      attrs = record_class.identifying_attribute_names
      if attrs.size == 1
        statement.where(
          attrs.first => records.flat_map { |record|
            record.original_attribute_values_at(attrs.first)
          }
        )
      else
        predicates = records.map { |record|
          SQL::Grouping.new(
            SQL::PredicateFragment.new(record.get_original_attributes(*attrs))
          )
        }
        statement.where(
          predicates.map(&:sql).join(' OR '),
          *predicates.flat_map(&:params)
        )
      end
    end

  end
end
