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
        update_all([record], record.updated_attributes(default: true))
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
        records.group_by { |record| record.updated_attributes(default: true) }.
          flat_map { |attrs, records| update_all(records, attrs) }
      end
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
        exec_with_record_map(conn, statement, records) do |record|
          record.updated!
        end
      end
    end

    def delete_records(statement, records)
      with_connection(writer) do |conn|
        exec_with_record_map(conn, statement, records) do |record|
          record.deleted!
        end
      end
    end

    def exec_with_record_map(conn, statement, records, &block)
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

    def add_values_clause(statement, record)
      params = []
      sql = record.all_attributes(default: true).map { |name, value|
        if value == Attribute::DEFAULT
          'DEFAULT'
        else
          params << value
          '$?'
        end
      }.join(', ')
      statement.values_sql(sql, *params)
    end

    def scope_to_records(records, statement)
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
