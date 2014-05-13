require 'spec_helper'

module Norm
  describe Connection do
    let(:mock_pg) { MiniTest::Mock.new }
    subject {
      PG::Connection.stub(:new, mock_pg) do
        Connection.new('primary')
      end
    }

    it 'requires a name' do
      proc { Connection.new }.must_raise ArgumentError
      mock_pg.expect(:new, mock_pg, [{}])
      PG::Connection.stub(:new, proc { |*args| mock_pg.new(*args) }) do
        Connection.new('primary').name.must_equal 'primary'
      end
    end

    it 'creates a database connection with options from initialize' do
      mock_pg.expect(:new, mock_pg, [{:host => 'zomg.lol'}])
      PG::Connection.stub(:new, proc { |*args| mock_pg.new(*args) }) do
        Connection.new('primary', :host => 'zomg.lol')
      end
      mock_pg.verify
    end

    describe '#exec_string' do

      it 'delegates to PG::Connection#exec' do
        mock_pg.expect(:exec, nil, &->(sql, &block) {
          sql == 'select 1' &&
          block.call('result') == 'called!'
        })
        subject.exec_string('select 1') do |result, conn|
          result.must_equal 'result'
          conn.must_be_kind_of Connection
          'called!'
        end
        mock_pg.verify
      end

      it 'does not require a block' do
        mock_pg.expect(:exec, nil, &->(sql, &block) {
          sql == 'select 1'
        })
        subject.exec_string('select 1')
        mock_pg.verify
      end

      it 'raises ConstraintError if PG::IntegrityConstraintViolation occurs' do
        check_violation = PG::CheckViolation.new
        mock_pg.expect(:exec, nil, &->(sql, &block) {
          raise check_violation
        })
        error = proc { subject.exec_string('select 1') }.
          must_raise ConstraintError
        error.message.must_equal 'Constraint violation'
        error.error.must_equal check_violation
        error.backtrace.must_equal check_violation.backtrace
      end

    end

    describe '#exec_params' do

      it 'delegates to PG::Connection#exec_params' do
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'select $1' &&
          params == [1] &&
          format == 0 &&
          block.call('result') == 'called!'
        })
        subject.exec_params('select $1', [1], 0) do |result, conn|
          result.must_equal 'result'
          conn.must_be_kind_of Connection
          'called!'
        end
        mock_pg.verify
      end

      it 'does not require a block' do
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'select $1' &&
          params == [1] &&
          format == 0
        })
        subject.exec_params('select $1', [1], 0)
        mock_pg.verify
      end

      it 'raises ConstraintError if PG::IntegrityConstraintViolation occurs' do
        check_violation = PG::CheckViolation.new
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          raise check_violation
        })
        error = proc { subject.exec_params('select $1', [1], 0) }.
          must_raise ConstraintError
        error.message.must_equal 'Constraint violation'
        error.error.must_equal check_violation
        error.backtrace.must_equal check_violation.backtrace
      end

    end

    describe '#exec_statement' do
      let(:statement) {
        SQL.statement(
          'insert into items values ($?, $?)',
          'A lovely item', 42
        )
      }

      it 'calls exec_params after replacing $? with numeric placeholders' do
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'insert into items values ($1, $2)' &&
          params == statement.params &&
          format == 1 &&
          block.call('result') == 'called!'
        })
        subject.exec_statement(statement, 1) do |result, conn|
          result.must_equal 'result'
          conn.must_be_kind_of Connection
          'called!'
        end
        mock_pg.verify
      end

      it 'does not require a block' do
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'insert into items values ($1, $2)' &&
          params == statement.params &&
          format == 1
        })
        subject.exec_statement(statement, 1)
        mock_pg.verify
      end

      it 'raises ConstraintError if PG::IntegrityConstraintViolation occurs' do
        check_violation = PG::CheckViolation.new
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          raise check_violation
        })
        error = proc { subject.exec_statement(statement, 1) }.
          must_raise ConstraintError
        error.message.must_equal 'Constraint violation'
        error.error.must_equal check_violation
        error.backtrace.must_equal check_violation.backtrace
      end

    end

    describe '#atomically' do

      it 'wraps its block in a transaction on first call' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['COMMIT'])
        subject.atomically do |conn|
          conn.must_be_same_as subject
        end
        mock_pg.verify
      end

      it 'executes a rollback and re-raises if the block raises an error' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['ROLLBACK'])
        error = proc {
          subject.atomically do |conn|
            conn.must_be_same_as subject
            raise 'zomg'
          end
        }.must_raise RuntimeError
        error.message.must_equal 'zomg'
        mock_pg.verify
      end

      it 'returns an unsuccessful result on constraint errors if handling' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['ROLLBACK'])
        result = subject.atomically handle_constraints: true do |conn|
          conn.must_be_same_as subject
          raise ConstraintError.new(PG::CheckViolation.new)
        end
        result.wont_be :success?
        result.error.must_be_kind_of ConstraintError
        mock_pg.verify
      end

      it 'wraps its block in a savepoint on second call' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['RELEASE SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['COMMIT'])
        subject.atomically do |conn|
          conn.atomically do |conn|
            conn.must_be_same_as subject
          end
        end
        mock_pg.verify
      end

      it 'rolls back to savepoint and re-raises if the block raises an error' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['ROLLBACK TO SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['ROLLBACK'])
        error = proc {
          subject.atomically do |conn|
            conn.atomically do |conn|
              conn.must_be_same_as subject
              raise 'zomg'
            end
          end
        }.must_raise RuntimeError
        error.message.must_equal 'zomg'
        mock_pg.verify
      end

      it 'increments number in savepoint name on additional calls' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_1'])
        mock_pg.expect(:exec, nil, ['RELEASE SAVEPOINT primary_1'])
        mock_pg.expect(:exec, nil, ['RELEASE SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['COMMIT'])
        subject.atomically do |conn|
          conn.atomically do |conn|
            conn.atomically do |conn|
              conn.must_be_same_as subject
            end
          end
        end
      end

      it 'allows rescue of specific errors to prevent cascading rollbacks' do
        mock_pg.expect(:exec, nil, ['BEGIN'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['SAVEPOINT primary_1'])
        mock_pg.expect(:exec, nil, ['ROLLBACK TO SAVEPOINT primary_1'])
        mock_pg.expect(:exec, nil, ['RELEASE SAVEPOINT primary_0'])
        mock_pg.expect(:exec, nil, ['COMMIT'])
        subject.atomically do |conn|
          conn.atomically do |conn|
            begin
              conn.atomically do |conn|
                conn.must_be_same_as subject
                raise 'zomg'
              end
            rescue RuntimeError => e
            end
          end
        end
      end

    end

  end
end
