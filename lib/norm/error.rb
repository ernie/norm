module Norm

  Error = Class.new(StandardError)
  ConnectionResetError = Class.new(Error)

  class ConstraintError < Error
    attr_reader :error

    def initialize(error, message = 'Norm::ConstraintError')
      @error = error
      super(message)
    end

  end

end
