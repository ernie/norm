require 'pg'
require 'norm/version'
require 'norm/result'
require 'norm/error'
require 'norm/parser'
require 'norm/sql'
require 'norm/connection'
require 'norm/connection_manager'
require 'norm/attribute'
require 'norm/attributes'
require 'norm/result_processor'
require 'norm/repository'
require 'norm/record'
require 'norm/record_delegator'

module Norm

  class << self
    attr_reader :connection_manager
  end

  def self.init!(connection_spec = {})
    @connection_manager = ConnectionManager.new(connection_spec)
  end

end
