require 'spec_helper'

module Norm
  module Parser
    describe Statement do
      let(:params) { {'qty' => 42, 'description' => 'A lovely item'} }
      let(:stmt)  {
        stmt = MiniTest::Mock.new
        stmt.expect(:params, params)
        stmt.expect(:format, :binary)
      }
      subject { Statement.new(stmt) }

      it 'replaces %{param} with $n and orders parameters' do
        stmt.expect(:sql, 'insert into items values (%{description}, %{qty})')
        subject
        stmt.verify
        subject.sql.must_equal 'insert into items values ($1, $2)'
        subject.params.must_equal ['A lovely item', 42]
      end

      it 'allows escaping of %{} with backslash' do
        stmt.expect(:sql, "select '\\%{string}'")
        subject
        stmt.verify
        subject.sql.must_equal "select '%{string}'"
        subject.params.must_equal []
      end

      it 'allows literal backslashes' do
        stmt.expect(:sql, "select '\\'")
        subject
        stmt.verify
        subject.sql.must_equal "select '\\'"
        subject.params.must_equal []
      end

      it 'translates format symbol to integer' do
        stmt.expect(:sql, 'ignore me')
        subject
        stmt.verify
        subject.format.must_equal 1
      end

    end
  end
end
