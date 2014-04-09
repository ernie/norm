module Norm
  class PostgreSQLRepository < Repository

    def insert_records(results, records)
      results.zip(records).map { |tuple, record|
        record.set_attributes(tuple)
        record.inserted!
      }
    end

    def update_records(results, records)
      updated_map = record_map(fetch_records(results))
      records.map! { |record|
        if matching_record = updated_map[record.attribute_values(*primary_keys)]
          record.set_attributes(matching_record.initialized_attributes)
          record.updated!
        end
        record
      }
    end

    def fetch_records(results)
      results.map { |tuple| record_class.from_repo(tuple) }
    end

    def delete_records(results, records)
    end

    def record_map(records)
      Hash[records.map { |record|
        [record.attribute_values(*primary_keys), record]
      }]
    end

  end
end
