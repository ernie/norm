module Norm

  Error = Class.new(StandardError)
  ConnectionResetError = Class.new(Error)

  class ConstraintError < Error

    class NullResult
      def error_field(name)
        nil
      end
    end

    attr_reader :error, :result

    def initialize(error, message = 'Norm::ConstraintError')
      @error, @result = error, error.result || NullResult.new
      super(message)
    end

    def respond_to_missing?(method_id, include_private = false)
      PG.const_defined?("PG_DIAG_#{method_id}".upcase) or super
    end

    def method_missing(method_id, *args, &block)
      const_name = "PG_DIAG_#{method_id}".upcase
      if PG.const_defined?(const_name)
        result.error_field(PG.const_get(const_name))
      else
        super
      end
    end

  end

end
