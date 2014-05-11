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

    def +(other)
      if self.success? && other.success?
        Result.new true, affected_rows: self.affected_rows + other.affected_rows
      else
        raise ArgumentError, 'Only successful results may be added'
      end
    end

  end
end
