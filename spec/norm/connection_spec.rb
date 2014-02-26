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
        mock_pg.expect(:exec, nil, ['select 1'])
        subject.exec_string('select 1')
        mock_pg.verify
      end
    end

    describe '#exec_params' do
      it 'delegates to PG::Connection#exec_params' do
        mock_pg.expect(:exec_params, nil, ['select $1', [1]])
        subject.exec_params('select $1', [1])
        mock_pg.verify
      end
    end

    describe '#process_query' do
      let(:params) { {'qty' => 42, 'description' => 'A lovely item'} }
      let(:query)  {
        query = MiniTest::Mock.new
        query.expect(:params, params)
      }

      it 'replaces :param with $n and orders parameters' do
        query.expect(:sql, 'insert into items values (:description, :qty)')
        sql, params = subject.process_query(query)
        query.verify
        sql.must_equal 'insert into items values ($1, $2)'
        params.must_equal ['A lovely item', 42]
      end

      it 'does not substitute :param if preceded by another colon' do
        query.expect(:sql, 'select 1::text')
        sql, params = subject.process_query(query)
        query.verify
        sql.must_equal 'select 1::text'
        params.must_equal []
      end

      it 'allows escaping of : with backslash' do
        query.expect(:sql, "select '\\:string'")
        sql, params = subject.process_query(query)
        query.verify
        sql.must_equal "select ':string'"
        params.must_equal []
      end

      it 'allows literal backslashes' do
        query.expect(:sql, 'select \\word')
        sql, params = subject.process_query(query)
        query.verify
        sql.must_equal "select \\word"
        params.must_equal []
      end

      it 'allows literal backslash before colons with a double backslash' do
        query.expect(:sql, 'select \\\\:word')
        sql, params = subject.process_query(query)
        query.verify
        sql.must_equal "select \\:word"
        params.must_equal []
      end

    end

  end
end
