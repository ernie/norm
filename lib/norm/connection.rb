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

    def process_query(query)
      counter = Range.new(1, Float::INFINITY).to_enum
      params_out = []
      sql_in, params_in = query.sql, query.params
      sql_out = sql_in.gsub(/(:|\\)?:(\w+)/) { |match|
        case $1
        when ':'
          match
        when '\\'
          ":#{$2}"
        else
          params_out << params_in[$2]
          "$#{counter.next}"
        end
      }
      [sql_out, params_out]
    end

  end
end
