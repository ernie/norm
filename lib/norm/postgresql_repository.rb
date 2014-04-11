module Norm
  class PostgreSQLRepository < Repository

    def all
      selecting(select_statement)
    end

    def fetch(*keys)
      selecting(fetch_statement(*keys)).first
    end

    def store(record_or_records)
      to_update, to_insert = Array(record_or_records).partition(&:stored?)
      insert(to_insert) + update(to_update)
    end

    def insert(record_or_records)
      inserting(insert_statement, Array(record_or_records))
    end

    def update(record_or_records)
      updating(update_statement, Array(record_or_records))
    end

    def delete(record_or_records)
      deleting(delete_statement, Array(record_or_records))
    end

    def selecting(statement)
      Norm.with_connection do |conn|
        conn.exec_statement(statement) do |result|
          result.map { |tuple| record_class.from_repo(tuple) }
        end
      end
    end

    def inserting(statement, records)
      insert_sql = records.inject(statement) { |stmt, record|
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
      }
      Norm.with_connection do |conn|
        conn.exec_statement(insert_sql) do |result|
          result.zip(records).map { |tuple, record|
            record.set_attributes(tuple)
            record.inserted!
          }
        end
      end
    end

  end
end
