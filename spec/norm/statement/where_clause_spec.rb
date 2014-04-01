require 'spec_helper'

module Norm
  module Statement
    describe WhereClause do

      it 'prefixes fragments with WHERE' do
        clause = WhereClause.new
        clause << Fragment.new('fragment')
        clause.sql.must_equal 'WHERE fragment'
      end

      it 'joins multiple fragments with AND' do
        clause = WhereClause.new
        clause << Fragment.new('fragment1')
        clause << Fragment.new('fragment2')
        clause.sql.must_equal 'WHERE fragment1 AND fragment2'
      end

      it 'has the params of its fragments' do
        clause = WhereClause.new
        clause << Fragment.new('fragment1', 1)
        clause << Fragment.new('fragment2', 2)
        clause.params.must_equal [1, 2]
      end

    end
  end
end
