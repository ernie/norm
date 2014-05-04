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

  def self.init!(connection_spec = {})
    @connection_manager = ConnectionManager.new(connection_spec)
  end

  def self.with_connections(*args, &block)
    @connection_manager.with_connections(*args, &block)
  end

  def self.with_connection(*args, &block)
    @connection_manager.with_connection(*args, &block)
  end

end
