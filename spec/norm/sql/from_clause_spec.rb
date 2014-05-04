require 'spec_helper'

module Norm
  module SQL
    describe FromClause do

      it 'prefixes fragments with FROM' do
        clause = FromClause.new
        clause << Fragment.new('fragment')
        clause.sql.must_equal 'FROM fragment'
      end

      it 'joins multiple fragments with commas' do
        clause = FromClause.new
        clause << Fragment.new('fragment1')
        clause << Fragment.new('fragment2')
        clause.sql.must_equal 'FROM fragment1, fragment2'
      end

      it 'has the params of its fragments' do
        clause = FromClause.new
        clause << Fragment.new('fragment1', 1)
        clause << Fragment.new('fragment2', 2)
        clause.params.must_equal [1, 2]
      end

    end
  end
end
