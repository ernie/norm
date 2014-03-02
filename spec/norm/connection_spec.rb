require 'spec_helper'

module Norm
  describe Connection do
    let(:mock_pg) { MiniTest::Mock.new }
    subject {
      PG::Connection.stub(:new, mock_pg) do
        Connection.new
      end
    }

    it 'creates a database connection with options from initialize' do
      mock_pg.expect(:new, mock_pg, [{:host => 'zomg.lol'}])
      PG::Connection.stub(:new, proc { |*args| mock_pg.new(*args) }) do
        Connection.new(:host => 'zomg.lol')
      end
      mock_pg.verify
    end

    describe '#exec_string' do
      it 'delegates to PG::Connection#exec' do
        blk = ->{}
        mock_pg.expect(:exec, nil, &->(sql, &block) {
          sql == 'select 1' &&
          block == blk
        })
        subject.exec_string('select 1', &blk)
        mock_pg.verify
      end
    end

    describe '#exec_params' do
      it 'delegates to PG::Connection#exec_params' do
        blk = ->{}
        mock_pg.expect(:exec_params, nil, &->(sql, params, format, &block) {
          sql == 'select $1' &&
          params == [1] &&
          format == 0 &&
          block == blk
        })
        subject.exec_params('select $1', [1], 0, &blk)
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
        blk = ->{}
        mock_pg.expect(:exec_params, blk, &->(sql, params, format, &block) {
          sql == 'insert into items values ($1, $2)' &&
          params == ['A lovely item', 42] &&
          format == 0 &&
          block == blk
        })
        subject.exec_statement(query, &blk)
        query.verify
        mock_pg.verify
      end
    end

  end
end
