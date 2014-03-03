require 'spec_helper'

module Norm
  describe Connection do
    let(:mock_pg) { MiniTest::Mock.new }
    subject {
      PG::Connection.stub(:new, mock_pg) do
        Connection.new('default')
      end
    }

    it 'requires a name' do
      proc { Connection.new }.must_raise ArgumentError
      mock_pg.expect(:new, mock_pg, [{}])
      Connection.new('default').name.must_equal 'default'
    end

    it 'creates a database connection with options from initialize' do
      mock_pg.expect(:new, mock_pg, [{:host => 'zomg.lol'}])
      PG::Connection.stub(:new, proc { |*args| mock_pg.new(*args) }) do
        Connection.new('default', :host => 'zomg.lol')
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
    end

    describe '#exec_statement' do
      let(:query) {
        query = MiniTest::Mock.new
        query.expect(:sql, 'insert into items values (%{description}, %{qty})')
        query.expect(:params, 'qty' => 42, 'description' => 'A lovely item')
        query.expect(:result_format, :text)
        query
      }

      it 'parses the query and calls exec_params on the result' do
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'insert into items values ($1, $2)' &&
          params == ['A lovely item', 42] &&
          format == 0 &&
          block.call('result') == 'called!'
        })
        subject.exec_statement(query) do |result, conn|
          result.must_equal 'result'
          conn.must_be_kind_of Connection
          'called!'
        end
        query.verify
        mock_pg.verify
      end
    end

  end
end
