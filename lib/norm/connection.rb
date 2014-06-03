module Norm
  class Connection

    PLACEHOLDER_FINALIZATION_REGEXP = /\\?\$\?/

    attr_reader :name, :db

    def initialize(name, opts = {})
      opts = opts.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      @setup       = opts.delete(:setup) { method(:default_setup) }
      @name        = name
      @db          = PG::Connection.new(opts)
      @transaction = false
      @savepoints  = []
      @setup.call(@db)
    end

    def transaction?
      @transaction
    end

    def reset
      @db.reset
      @setup.call(@db)
    end

    def exec_string(*args, &block)
      handling_errors do
        @db.exec(*args) do |result|
          yield result, self if block_given?
        end
      end
    end

    def exec_params(*args, &block)
      handling_errors do
        @db.exec_params(*args) do |result|
          yield result, self if block_given?
        end
      end
    end

    def exec_statement(stmt, result_format = 0, &block)
      handling_errors do
        sql = finalize_placeholders(stmt.sql)
        @db.exec_params(sql, stmt.params, result_format) do |result|
          yield result, self if block_given?
        end
      end
    end

    def atomically(&block)
      if transaction?
        _with_savepoint(&block)
      else
        _with_transaction(&block)
      end
    end

    private

    def default_setup(db)
      db.exec('SET application_name = "norm"')
      db.exec('SET bytea_output = "hex"')
      db.exec('SET backslash_quote = "safe_encoding"')
    end

    def handling_errors(&block)
      yield
    rescue PG::UnableToSend => e
      reset
      raise ConnectionResetError, 'The DB connection was reset',
        e.backtrace
    rescue PG::IntegrityConstraintViolation => e
      raise Norm::Constraint::ConstraintError.new(e),
        'Constraint violation', e.backtrace
    end

    def _with_savepoint(&block)
      name = "#{@name}_#{@savepoints.size}"
      @savepoints << name
      exec_string("SAVEPOINT #{name}")
      result = yield self
      exec_string("RELEASE SAVEPOINT #{name}")
      result
    rescue Exception => e
      exec_string("ROLLBACK TO SAVEPOINT #{name}")
      raise e
    ensure
      @savepoints.pop
    end

    def _with_transaction(&block)
      @transaction = true
      exec_string('BEGIN')
      result = yield self
      exec_string('COMMIT')
      result
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
