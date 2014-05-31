module Norm
  class RecordMutationProcessor < ResultProcessor

    def select_one
      yield ->(result, conn) {
        result.map { |tuple| record_class.from_repo(tuple) }.first
      }
    end

    def select_many
      yield ->(result, conn) {
        result.map { |tuple| record_class.from_repo(tuple) }
      }
    end

    def insert_one(record)
      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.inserted!
      }
      true
    rescue ConstraintError => e
      false
    end

    def update_one(record)
      return true unless record.updated_attributes?

      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.updated!
      }
      true
    rescue ConstraintError => e
      false
    end

    def delete_one(record)
      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.deleted!
      }
      true
    rescue ConstraintError => e
      false
    end

  end
end
