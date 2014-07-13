require 'spec_helper'

module Norm
  module SQL
    describe WithClause do
      subject { WithClause.new }

      describe 'initialization' do

        it 'defaults recursive to false' do
          subject.wont_be :recursive?
        end

      end

      describe '#recursive!' do

        it 'sets the with clause to be recursive' do
          subject.recursive!
          subject.must_be :recursive?
        end

      end

      describe '#sql' do

        it 'prepends WITH to fragment SQL' do
          cte = CTE.new(:name, Statement.new('foo'))
          subject << cte
          subject.sql.must_equal 'WITH "name" AS (foo)'
        end

        it 'joins fragments with commas' do
          cte1 = CTE.new(:name, Statement.new('foo'))
          cte2 = CTE.new(:another, Statement.new('bar'))
          subject << cte1 << cte2
          subject.sql.must_equal 'WITH "name" AS (foo), "another" AS (bar)'
        end

        it 'includes RECURSIVE if the clause is recursive' do
          cte = CTE.new(:name, Statement.new('foo'))
          subject << cte
          subject.recursive!
          subject.sql.must_equal 'WITH RECURSIVE "name" AS (foo)'
        end

      end

    end
  end
end
