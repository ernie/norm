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

    def noop_one(record)
      record.valid? && true
    end

    def noop_many(records)
      records = Norm::Record::Collection(records)
      records.valid? && true
    end

    # Update the record's attributes and mark it as inserted if the query
    # succeeds. Note that a possible (expected) failure case is a constraint
    # error. Since we rescue and return false in this case, it's important that
    # client code wraps the statement in a transaction before executing it, to
    # so the transaction will have been rolled back before the constraint error
    # is rescued here.
    def insert_one(record, constraint_delegate: record)
      return false unless record.valid?

      yield ->(result, conn) {
        assert_result_size(1, result)
        record.set_attributes(result.first) and record.inserted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error(e)
      false
    end

    def insert_many(records, constraint_delegate: nil)
      records = Norm::Record::Collection(records)
      return false unless records.valid?

      yield ->(result, conn) {
        assert_result_size(records.size, result)
        records.insert_attributes(result) and records.inserted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate ||= records
      constraint_delegate.constraint_error(e)
      false
    end

    def update_one(record, constraint_delegate: record)
      return false unless record.valid?

      yield ->(result, conn) {
        assert_result_size(1, result)
        record.set_attributes(result.first) and record.updated!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error(e)
      false
    end

    def update_many(records, constraint_delegate: nil)
      records = Norm::Record::Collection(records)
      return false unless records.valid?

      yield ->(result, conn) {
        assert_result_size(records.size, result)
        records.set_attributes(result) and records.updated!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate ||= records
      constraint_delegate.constraint_error(e)
      false
    end

    def delete_one(record, constraint_delegate: record)
      return true if record.deleted?

      yield ->(result, conn) {
        assert_result_size(1, result)
        record.set_attributes(result.first) and record.deleted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate.constraint_error(e)
      false
    end

    def delete_many(records, constraint_delegate: nil)
      records = Norm::Record::Collection(records)
      return true if records.deleted?

      yield ->(result, conn) {
        assert_result_size(records.size, result)
        records.set_attributes(result) and records.deleted!
      }
      true
    rescue Constraint::ConstraintError => e
      constraint_delegate ||= records
      constraint_delegate.constraint_error(e)
      false
    end

  end
end
