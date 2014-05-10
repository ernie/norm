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
      insert_records(add_values_clause(insert_statement, record), [record])
    end

    def mass_insert(records)
      insert_records(
        records.reduce(insert_statement) { |stmt, record|
          add_values_clause(stmt, record)
        },
        records
      )
    end

    def update(record)
      if record.updated_attributes?
        update_all([record], record.updated_attributes)
      else
        true
      end
    end

    def mass_update(records, attrs = nil)
      if attrs
        update_all(records, attrs)
      else
        records.group_by(&:updated_attributes).flat_map { |attrs, records|
          attrs.empty? ? true : update_all(records, attrs)
        }.all?
      end
    end

    def store(record)
      record.stored? ? update(record) : insert(record)
    end

    def mass_store(records)
      to_update, to_insert = records.partition(&:stored?)
      mass_insert(to_insert) && mass_update(to_update)
    end

    def delete(record)
      delete_records(scope_to_records([record], delete_statement), [record])
    end

    def mass_delete(records)
      delete_records(scope_to_records(records, delete_statement), records)
    end

    def returning_result(&block)
      yield
      # return a successful result object
    rescue PG::Error => e
      # Return an unsuccessful result object
    end

    private

    def update_all(records, attrs)
      update_records(
        scope_to_records(records, update_statement.set(attrs)),
        records
      )
    end

    def select_records(statement)
      with_connection do |conn|
        conn.exec_statement(statement) do |result|
          result.map { |tuple| record_class.from_repo(tuple) }
        end
      end
    end

    def insert_records(statement, records)
      with_connection do |conn|
        conn.exec_statement(statement) do |result|
          result.zip(records).each { |tuple, record|
            record.set_attributes(tuple)
            record.inserted!
          }
          true
        end
      end
    end

    def update_records(statement, records)
      with_connection do |conn|
        conn.exec_statement(statement) do |result|
          update_map = record_map(records)
          result.each { |tuple|
            updated = record_class.from_repo(tuple)
            if record = update_map[updated.values_at(*primary_keys)]
              record.set_attributes(updated.initialized_attributes)
              record.updated!
            end
          }
          true
        end
      end
    end

    def delete_records(statement, records)
      with_connection do |conn|
        conn.exec_statement(statement) do |result|
          delete_map = record_map(records)
          result.each { |tuple|
            deleted = record_class.from_repo(tuple)
            if record = delete_map[deleted.values_at(*primary_keys)]
              record.set_attributes(deleted.initialized_attributes)
              record.deleted!
            end
          }
          true
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
