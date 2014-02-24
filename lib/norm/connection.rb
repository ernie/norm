module Norm
  class Connection

    def initialize(opts = {})
      @db = PG::Connection.new(opts)
    end

    def exec_string(sql, &block)
      @db.exec(sql, &block)
      # raw_exec_string(query) do |result|
      #   result.to_a.map { |tuple| loader.new tuple }
      # end
    end

    def exec_params(sql, params = {}, format = 0, &block)
      @db.exec_params(sql, params, format, &block)
    end

  end
end
