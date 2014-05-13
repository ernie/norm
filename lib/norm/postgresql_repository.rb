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
        insert_records(add_values_clause(insert_statement, record), [record])
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
        update_all([record], record.updated_attributes)
      end
    end

    def mass_update(records, attrs = nil)
      atomically_on(writer, result: true) do
        do_mass_update(records, attrs)
      end
    end

    def store(record)
      atomically_on(writer, result: true) do
        record.stored? ? update(record) : insert(record)
      end
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
        delete_records(scope_to_records([record], delete_statement), [record])
      end
    end

    def mass_delete(records)
      atomically_on(writer, result: true) do
        delete_records(scope_to_records(records, delete_statement), records)
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
          add_values_clause(stmt, record)
        },
        records
      )
    end

    def do_mass_update(records, attrs = nil)
      if attrs
        update_all(records, attrs)
      else
        records.group_by(&:updated_attributes).
          flat_map { |attrs, records| update_all(records, attrs) }
      end
      success!
    end

    def update_all(records, attrs)
      return success! if records.empty?

      update_records(
        scope_to_records(records, update_statement.set(attrs)),
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

    def update_records(statement, records)
      with_connection(writer) do |conn|
        conn.exec_statement(statement) do |result|
          update_map = record_map(records)
          result.each { |tuple|
            updated = record_class.from_repo(tuple)
            if record = update_map[updated.values_at(*primary_keys)]
              record.set_attributes(updated.initialized_attributes)
              record.updated!
            end
          }
        end
      end
    end

    def delete_records(statement, records)
      with_connection(writer) do |conn|
        conn.exec_statement(statement) do |result|
          delete_map = record_map(records)
          result.each { |tuple|
            deleted = record_class.from_repo(tuple)
            if record = delete_map[deleted.values_at(*primary_keys)]
              record.set_attributes(deleted.initialized_attributes)
              record.deleted!
            end
          }
          success!
        end
      end
    end

    def record_map(records)
      Hash[ records.map { |record| [record.values_at(*primary_keys), record] } ]
    end

    def add_values_clause(statement, record)
      attrs = record.initialized_attributes
      params = []
      sql = record_class.attribute_names.map { |name|
        if attrs.key?(name)
          params << attrs[name]
          '$?'
        else
          'DEFAULT'
        end
      }.join(', ')
      statement.values_sql(sql, *params)
    end

    def scope_to_records(records, statement)
      return statement.where('FALSE') if records.empty?

      if primary_keys.size == 1
        key = primary_keys.first
        values = records.map(&key.to_sym)
        statement.where(key => records.map(&key.to_sym))
      else
        preds = records.map { |record| record.read_attributes(*primary_keys) }.
          map { |attrs|
            SQL::Grouping.new(SQL::PredicateFragment.new(attrs))
          }
        statement.where(
          preds.map(&:sql).join(' OR '),
          *preds.map(&:params).flatten!
        )
      end
    end

  end
end
