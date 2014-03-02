module Norm
  class Connection
    attr_reader :db

    def initialize(opts = {})
      @db = PG::Connection.new(opts)
    end

    def exec_string(*args, &block)
      @db.exec(*args, &block)
    end

    def exec_params(*args, &block)
      @db.exec_params(*args, &block)
    end

    def exec_statement(statement, &block)
      parsed = Parser::Statement.new(statement)
      @db.exec_params(parsed.sql, parsed.params, parsed.result_format, &block)
    end

  end
end
