module Norm
  class Result
    attr_reader :value

    def initialize(success, value = nil)
      if Result === value
        @success = value.success?
        @value   = value.value
      else
        @success = success
        @value   = value
      end
    end

    def success?
      @success
    end

    def error?
      !@success
    end

  end
end
