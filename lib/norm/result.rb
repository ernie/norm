module Norm
  class Result
    attr_reader :error

    def initialize(success, error = nil)
      @success = success
      @error   = error
    end

    def success?
      @success
    end

  end
end
