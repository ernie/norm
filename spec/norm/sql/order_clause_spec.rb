require 'spec_helper'

module Norm
  module SQL
    describe OrderClause do

      it 'prefixes fragments with ORDER BY' do
        clause = OrderClause.new
        clause << Fragment.new('fragment')
        clause.sql.must_equal 'ORDER BY fragment'
      end

      it 'joins multiple fragments with commas' do
        clause = OrderClause.new
        clause << Fragment.new('fragment1')
        clause << Fragment.new('fragment2')
        clause.sql.must_equal 'ORDER BY fragment1, fragment2'
      end

      it 'has the params of its fragments' do
        clause = OrderClause.new
        clause << Fragment.new('fragment1', 1)
        clause << Fragment.new('fragment2', 2)
        clause.params.must_equal [1, 2]
      end

    end
  end
end
