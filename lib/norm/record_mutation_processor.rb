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

    # Update the record's attributes and mark it as inserted if the query
    # succeeds. Note that a possible (expected) failure case is a constraint
    # error. Since we rescue and return false in this case, it's important that
    # client code wraps the statement in a transaction before executing it, to
    # so the transaction will have been rolled back before the constraint error
    # is rescued here.
    def insert_one(record, constraint_delegate = record)
      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.inserted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error!(e)
      false
    end

    def update_one(record, constraint_delegate = record)
      return true unless record.updated_attributes?

      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.updated!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error!(e)
      false
    end

    def delete_one(record, constraint_delegate = record)
      return true if record.deleted?

      yield ->(result, conn) {
        require_one_result!(result)
        record.set_attributes(result.first) and record.deleted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error!(e)
      false
    end

  end
end
