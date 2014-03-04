module Norm
  class Connection
    attr_reader :name, :db

    def initialize(name, opts = {})
      @name = name
      @db   = PG::Connection.new(opts)
    end

    def exec_string(*args, &block)
      @db.exec(*args) do |result|
        yield result, self
      end
    end

    def exec_params(*args, &block)
      @db.exec_params(*args) do |result|
        yield result, self
      end
    end

    def exec_statement(stmt, &block)
      @db.exec_params(stmt.sql, stmt.params, stmt.result_format) do |result|
        yield result, self
      end
    end

  end
end
