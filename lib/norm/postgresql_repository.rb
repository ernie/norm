module Norm
  class PostgreSQLRepository < Repository

    def all
      selecting(select_statement)
    end

    def fetch(*keys)
      attributes = load_attributes(Hash[primary_keys.zip(keys)])
      selecting(select_statement.where(attributes)).first
    end

    def store(record_or_records)
      to_update, to_insert = Array(record_or_records).partition(&:stored?)
      insert(to_insert) + update(to_update)
    end

    def insert(record_or_records)
      records = Array(record_or_records)
      inserting(build_insert(records), records)
    end

    def update(record_or_records)
      records = Array(record_or_records)
      records.group_by(&:updated_attributes).flat_map { |attrs, records|
        attrs.empty? ? [] : update_all(records, attrs)
      }
    end

    def update_all(records, attrs)
      updating(
        scope_to_records(records, update_statement.set(attrs)),
        records
      )
    end

    def scope_to_records(records, statement)
      if primary_keys.size == 1
        key = primary_keys.first
        values = records.map(&key.to_sym)
        statement.where(key => records.map(&key.to_sym))
      else
        preds = records.map { |record| record.read_attributes(*primary_keys) }.
          map { |attrs|
            Statement::Grouping.new(Statement::PredicateFragment.new(attrs))
          }
        statement.where(
          preds.map(&:sql).join(' OR '),
          *preds.map(&:params).flatten!
        )
      end
    end

    def delete(record_or_records)
      records = Array(record_or_records)
      deleting(scope_to_records(records, delete_statement), records)
    end

    def selecting(statement)
      Norm.with_connection do |conn|
        conn.exec_statement(statement) do |result|
          result.map { |tuple| record_class.from_repo(tuple) }
        end
      end
    end

    def inserting(statement, records)
      Norm.with_connection do |conn|
        conn.exec_statement(statement) do |result|
          result.zip(records).map { |tuple, record|
            record.set_attributes(tuple)
            record.inserted!
          }
        end
      end
    end

    def build_insert(records)
      records.inject(insert_statement) { |stmt, record|
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
        stmt.values_sql(sql, *params)
      }
    end

    def updating(statement, records)
      Norm.with_connection do |conn|
        conn.exec_statement(statement) do |result|
          update_map = record_map(records)
          result.each { |tuple|
            updated = record_class.from_repo(tuple)
            if record = update_map[updated.attribute_values(*primary_keys)]
              record.set_attributes(updated.initialized_attributes)
              record.updated!
            end
          }
          records
        end
      end
    end

    def deleting(statement, records)
      Norm.with_connection do |conn|
        conn.exec_statement(statement) do |result|
          delete_map = record_map(records)
          result.each { |tuple|
            deleted = record_class.from_repo(tuple)
            if record = delete_map[deleted.attribute_values(*primary_keys)]
              record.set_attributes(deleted.initialized_attributes)
              record.deleted!
            end
          }
          records
        end
      end
    end

    def record_map(records)
      Hash[records.map { |record|
        [record.attribute_values(*primary_keys), record]
      }]
    end

  end
end
