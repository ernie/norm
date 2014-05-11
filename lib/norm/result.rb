module Norm
  class Result
    attr_reader :affected_rows, :constraint_error

    def initialize(success, affected_rows: 0, constraint_error: nil)
      @success          = success
      @affected_rows    = affected_rows
      @constraint_error = constraint_error
    end

    def success?
      @success
    end

    def to_ary
      [@success, @constraint_error]
    end
    alias :to_a :to_ary

  end
end
