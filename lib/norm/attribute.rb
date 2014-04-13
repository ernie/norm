require 'norm/attribute/loading'
require 'norm/attribute/delegator'
require 'norm/attribute/loader'

require 'norm/attribute/integer'
require 'norm/attribute/decimal'
require 'norm/attribute/character'
require 'norm/attribute/string'
require 'norm/attribute/binary'
require 'norm/attribute/timestamp'
require 'norm/attribute/date'
require 'norm/attribute/time'
require 'norm/attribute/interval'

module Norm
  module Attribute

    Error = Class.new(::Norm::Error)
    LoadingError = Class.new(Error)

  end
  Attr = Attribute
end
