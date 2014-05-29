module Norm
  class PostgreSQLRepository < Repository

    def all
      select_records(select_statement)
    end

    def fetch(*keys)
      attributes = load_attributes(Hash[primary_keys.zip(keys)])
      select_records(select_statement.where(attributes)).first
    end

    def insert(record)
      atomically_on(writer, result: true) do
        exec_for_record(
          writer,
          insert_statement.values(
            *record.attribute_values_at(*attribute_names, default: true)
          ),
          record
        ) do |record|
          record.inserted!
        end
      end
    end

    def mass_insert(records)
      atomically_on(writer, result: true) do
        do_mass_insert(records)
      end
    end

    def update(record)
      return success! unless record.updated_attributes?

      atomically_on(writer, result: true) do
        update_record(
          scope_to_record(
            update_statement.set(record.updated_attributes(default: true)),
            record
          ),
          record
        )
      end
    end

    def mass_update(records, attrs = nil)
      atomically_on(writer, result: true) do
        do_mass_update(records, attrs)
      end
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def mass_store(records)
      atomically_on(writer, result: true) do
        to_update, to_insert = records.partition(&:stored?)
        do_mass_update(to_update)
        do_mass_insert(to_insert)
      end
    end

    def delete(record)
      atomically_on(writer, result: true) do
        delete_record(scope_to_record(delete_statement, record), record)
      end
    end

    def mass_delete(records)
      atomically_on(writer, result: true) do
        delete_records(scope_to_records(delete_statement, records), records)
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

    def do_mass_insert(records)
      insert_records(
        records.reduce(insert_statement) { |stmt, record|
          stmt.values(
            *record.attribute_values_at(*attribute_names, default: true)
          )
        },
        records
      )
    end

    def do_mass_update(records, attrs = nil)
      if attrs
        update_all(records, attrs)
      else
        records.group_by { |record| record.updated_attributes(default: true) }.
          flat_map { |attrs, records| update_all(records, attrs) }
      end
    end

    def update_all(records, attrs)
      return success! if records.empty?

      update_records(
        scope_to_records(update_statement.set(attrs), records),
        records
      )
    end

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

    def insert_records(statement, records)
      with_connection(writer) do |conn|
        conn.exec_statement(statement) do |result|
          result.zip(records).each { |tuple, record|
            record.set_attributes(tuple)
            record.inserted!
          }
        end
      end
    end

    def update_record(statement, record)
      exec_for_record(writer, statement, record) do |record|
        record.updated!
      end
    end

    def update_records(statement, records)
      exec_for_records(writer, statement, records) do |record|
        record.updated!
      end
    end

    def delete_record(statement, record)
      exec_for_record(writer, statement, record) do |record|
        record.deleted!
      end
    end

    def delete_records(statement, records)
      exec_for_records(writer, statement, records) do |record|
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

    def exec_for_records(connection_name, statement, records, &block)
      with_connection(connection_name) do |conn|
        conn.exec_statement(statement) do |result|
          map = RecordMap.new(records, primary_keys)
          result.each do |tuple|
            repo_record = record_class.from_repo(tuple)
            if record = map.fetch(repo_record)
              record.set_attributes(repo_record.initialized_attributes)
              yield record
            end
          end
        end
      end
    end

    def scope_to_record(statement, record)
      statement.where(record.get_original_attributes(*primary_keys))
    end

    def scope_to_records(statement, records)
      return statement.where('FALSE') if records.empty?

      if primary_keys.size == 1
        key = primary_keys.first
        statement.where(key => records.map { |r| r.attributes.orig(key) } )
      else
        scope_with_composite_primary_keys(records, statement)
      end
    end

    def scope_with_composite_primary_keys(records, statement)
      preds = records.map { |record|
        SQL::Grouping.new(SQL::PredicateFragment.new(
          record.get_original_attributes(*primary_keys)
        ))
      }
      statement.where(
        preds.map(&:sql).join(' OR '),
        *preds.flat_map(&:params)
      )
    end

  end
end
