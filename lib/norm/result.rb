module Norm
  class Result
    attr_reader :value

    def self.for(object)
      Result === object ? object : SuccessResult.new(object)
    end

    def self.capture(*captured_error_classes)
      Result.for(yield)
    rescue *captured_error_classes => e
      ErrorResult.new(e)
    end

    def initialize(value = nil)
      @value = value
    end

    def success?
      raise NotImplementedError, 'Result subclasses must implement success?'
    end

    def error?
      !success?
    end

    def to_ary
      [success?, value]
    end
    alias :to_a :to_ary

  end
end

require 'norm/success_result'
require 'norm/error_result'
