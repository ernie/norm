module Norm
  class ResultProcessor
    attr_reader :record_class

    def initialize(record_class)
      @record_class = record_class
    end

    def select_one
      raise NotImplementedError, "This processor doesn't implement #select_one"
    end

    def select_many
      raise NotImplementedError, "This processor doesn't implement #select_many"
    end

    def insert_one(record)
      raise NotImplementedError, "This processor doesn't implement #insert_one"
    end

    def insert_many(records)
      raise NotImplementedError, "This processor doesn't implement #insert_many"
    end

    def update_one(record)
      raise NotImplementedError, "This processor doesn't implement #update_one"
    end

    def update_many(records)
      raise NotImplementedError, "This processor doesn't implement #update_many"
    end

    def delete_one(record)
      raise NotImplementedError, "This processor doesn't implement #delete_one"
    end

    def delete_many(records)
      raise NotImplementedError, "This processor doesn't implement #delete_many"
    end

    private

    def require_one_result!(result)
      if result.ntuples < 1
        raise NotFoundError, 'No results for query!'
      elsif result.ntuples > 1
        raise TooManyResultsError,
          "#{result.ntuples} rows returned when only one was expected."
      end
    end

  end
end

require 'norm/record_mutation_processor'
