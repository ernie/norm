module Norm

  Error = Class.new(StandardError)
  ConnectionResetError = Class.new(Error)
  NotFoundError = Class.new(Error)
  TooManyResultsError = Class.new(Error)

end
