require 'spec_helper'

module Norm
  module Parser
    describe Query do
      let(:params) { {'qty' => 42, 'description' => 'A lovely item'} }
      let(:query)  {
        query = MiniTest::Mock.new
        query.expect(:params, params)
      }
      subject { Query.new(query) }

      it 'replaces %{param} with $n and orders parameters' do
        query.expect(:sql, 'insert into items values (%{description}, %{qty})')
        subject
        query.verify
        subject.sql.must_equal 'insert into items values ($1, $2)'
        subject.params.must_equal ['A lovely item', 42]
      end

      it 'allows escaping of %{} with backslash' do
        query.expect(:sql, "select '\\%{string}'")
        subject
        query.verify
        subject.sql.must_equal "select '%{string}'"
        subject.params.must_equal []
      end

      it 'allows literal backslashes' do
        query.expect(:sql, "select '\\'")
        subject
        query.verify
        subject.sql.must_equal "select '\\'"
        subject.params.must_equal []
      end

    end
  end
end
