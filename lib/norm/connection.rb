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

    def parse_query(query)
      parsed = Parser::Query.new(query)
      [parsed.sql, parsed.params]
    end

  end
end
