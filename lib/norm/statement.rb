require 'norm/statement/sql'
require 'norm/statement/select'
require 'norm/statement/insert'
require 'norm/statement/update_one_by_primary_keys'
require 'norm/statement/delete'

module Norm
  module Statement

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