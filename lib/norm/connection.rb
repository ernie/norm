module Norm
  class Connection

    PLACEHOLDER_FINALIZATION_REGEXP = /\\?\$\?/

    attr_reader :name, :db

    def initialize(name, opts = {})
      @name        = name
      @db          = PG::Connection.new(opts)
      @transaction = false
      @savepoints  = []
    end

    def transaction?
      @transaction
    end

    def exec_string(*args, &block)
      @db.exec(*args) do |result|
        yield result, self if block_given?
      end
    rescue PG::IntegrityConstraintViolation => e
      raise Norm::ConstraintError.new(e), 'Constraint violation', e.backtrace
    end

    def exec_params(*args, &block)
      @db.exec_params(*args) do |result|
        yield result, self if block_given?
      end
    rescue PG::IntegrityConstraintViolation => e
      raise Norm::ConstraintError.new(e), 'Constraint violation', e.backtrace
    end

    def exec_statement(stmt, result_format = 0, &block)
      sql = finalize_placeholders(stmt.sql)
      @db.exec_params(sql, stmt.params, result_format) do |result|
        yield result, self if block_given?
      end
    rescue PG::IntegrityConstraintViolation => e
      raise Norm::ConstraintError.new(e), 'Constraint violation', e.backtrace
    end

    def atomically(&block)
      if transaction?
        _with_savepoint(&block)
      else
        _with_transaction(&block)
      end
    end

    private

    def _with_savepoint(&block)
      name = "#{@name}_#{@savepoints.size}"
      @savepoints << name
      exec_string("SAVEPOINT #{name}")
      yield self
      exec_string("RELEASE SAVEPOINT #{name}")
    rescue Exception => e
      exec_string("ROLLBACK TO SAVEPOINT #{name}")
      raise e
    ensure
      @savepoints.pop
    end

    def _with_transaction(&block)
      @transaction = true
      exec_string('BEGIN')
      yield self
      exec_string('COMMIT')
    rescue Exception => e
      exec_string('ROLLBACK')
      raise e
    ensure
      @transaction = false
    end

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
