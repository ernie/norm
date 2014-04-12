module Norm

  Error = Class.new(StandardError)
  # TODO: These errors are very memory repository specific, and they suck
  NotFoundError = Class.new(Error)
  InvalidKeyError = Class.new(Error)
  DuplicateKeyError = Class.new(Error)

end
