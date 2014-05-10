require 'pg'
require 'norm/version'
require 'norm/error'
require 'norm/identity'
require 'norm/parser'
require 'norm/sql'
require 'norm/connection'
require 'norm/connection_manager'
require 'norm/attribute'
require 'norm/repository'
require 'norm/record'

module Norm

  class << self
    attr_reader :connection_manager
  end

  def self.init!(connection_spec = {})
    @connection_manager = ConnectionManager.new(connection_spec)
  end

end
