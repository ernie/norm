require 'norm/statement/value_clause'
require 'norm/statement/collection_clause'
require 'norm/statement/fragment'
require 'norm/statement/predicate_fragment'
require 'norm/statement/set_fragment'
require 'norm/statement/grouping'
require 'norm/statement/sql'
require 'norm/statement/select'
require 'norm/statement/insert'
require 'norm/statement/update'
require 'norm/statement/delete'

module Norm
  module Statement

    MissingInterpolationError = Class.new(Error)

    def self.sql(*args, &block)
      SQL.new(*args, &block)
    end

    def self.select(*args, &block)
      Select.new(*args, &block)
    end

    def self.insert(*args, &block)
      Insert.new(*args, &block)
    end

    def self.update(*args, &block)
      Update.new(*args, &block)
    end

    def self.delete(*args, &block)
      Delete.new(*args, &block)
    end

  end
end
