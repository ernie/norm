require 'norm/statement/statement'
require 'norm/statement/select'
require 'norm/statement/insert'
require 'norm/statement/update'
require 'norm/statement/delete'

module Norm
  module Statement

    def self.new(*args, &block)
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
