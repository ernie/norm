module Norm

  Error = Class.new(StandardError)
  ConnectionResetError = Class.new(Error)
  NotFoundError = Class.new(Error)
  ResultMismatchError = Class.new(Error)

end
