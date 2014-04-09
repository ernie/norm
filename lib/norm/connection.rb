module Norm
  class Connection

    PLACEHOLDER_FINALIZATION_REGEXP = /\\?\$\?/

    attr_reader :name, :db

    def initialize(name, opts = {})
      @name = name
      @db   = PG::Connection.new(opts)
    end

    def exec_string(*args, &block)
      @db.exec(*args) do |result|
        yield result, self if block_given?
      end
    end

    def exec_params(*args, &block)
      @db.exec_params(*args) do |result|
        yield result, self if block_given?
      end
    end

    def exec_statement(stmt, result_format = 0, &block)
      sql = finalize_placeholders(stmt.sql)
      @db.exec_params(sql, stmt.params, result_format) do |result|
        yield result, self if block_given?
      end
    end

    private

    def finalize_placeholders(sql)
      counter = (1..65536).to_enum
      sql.gsub(PLACEHOLDER_FINALIZATION_REGEXP) { |match|
        if match.start_with? '\\'
          '$?'
        else
          "$#{counter.next}"
        end
      }
    end

  end
end
