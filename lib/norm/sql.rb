require 'norm/sql/value_clause'
require 'norm/sql/collection_clause'
require 'norm/sql/fragment'
require 'norm/sql/predicate_fragment'
require 'norm/sql/set_fragment'
require 'norm/sql/cte'
require 'norm/sql/grouping'
require 'norm/sql/statement'
require 'norm/sql/select'
require 'norm/sql/insert'
require 'norm/sql/update'
require 'norm/sql/delete'

module Norm
  module SQL

    MissingInterpolationError = Class.new(Error)

    def self.statement(*args, &block)
      Statement.new(*args, &block)
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
