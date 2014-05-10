module Norm

  Error = Class.new(StandardError)

  class ConstraintError < Error
    attr_reader :error

    def initialize(error, message = 'Norm::ConstraintError')
      @error = error
      super(message)
    end

  end

end
