require 'spec_helper'

module Norm
  module Statement
    describe HavingClause do

      it 'prefixes fragments with HAVING' do
        clause = HavingClause.new
        clause << Fragment.new('fragment')
        clause.sql.must_equal 'HAVING fragment'
      end

      it 'joins multiple fragments with AND' do
        clause = HavingClause.new
        clause << Fragment.new('fragment1')
        clause << Fragment.new('fragment2')
        clause.sql.must_equal 'HAVING fragment1 AND fragment2'
      end

      it 'has the params of its fragments' do
        clause = HavingClause.new
        clause << Fragment.new('fragment1', 1)
        clause << Fragment.new('fragment2', 2)
        clause.params.must_equal [1, 2]
      end

    end
  end
end
