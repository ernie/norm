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

  end
end
