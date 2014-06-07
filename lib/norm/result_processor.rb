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

    def insert_one(record, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #insert_one"
    end

    def insert_many(records, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #insert_many"
    end

    def update_one(record, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #update_one"
    end

    def update_many(records, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #update_many"
    end

    def delete_one(record, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #delete_one"
    end

    def delete_many(records, constraint_delegate: raise_delegate)
      raise NotImplementedError, "This processor doesn't implement #delete_many"
    end

    private

    def assert_result_size(size, result)
      if result.ntuples != size
        raise ResultMismatchError,
          "#{result.ntuples} results returned, but #{size} was expected"
      end
    end

    def raise_delegate
      @raise_delegate ||= Constraint::RaiseDelegate.new
    end

  end
end

require 'norm/record_mutation_processor'
