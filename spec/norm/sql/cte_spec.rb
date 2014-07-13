require 'spec_helper'

module Norm
  module SQL
    describe CTE do

      describe 'initialization' do
        subject { CTE }

        it 'requires a table and statement' do
          proc { subject.new }.must_raise ArgumentError
          proc { subject.new :table }.must_raise ArgumentError
          subject.new(:table, :statement).must_be_kind_of CTE
        end

      end

      describe '#table' do

        it 'is an identifier for the supplied parameter on intialization' do
          cte = CTE.new(:table, :statement)
          cte.table.to_s.must_equal '"table"'
        end

      end

      describe '#statement' do

        it 'is the supplied statement on initialization' do
          cte = CTE.new(:table, :statement)
          cte.statement.must_equal :statement
        end

      end

      describe '#columns' do

        it 'is an array of identifiers for the values from initialization' do
          cte = CTE.new(:table, :statement, columns: [:id, :name])
          cte.columns.map(&:to_s).must_equal ['"id"', '"name"']
        end

      end

      describe '#params' do

        it 'is the statement params' do
          statement = Statement.new('zomg', :bbq)
          cte = CTE.new(:table, statement)
          cte.params.must_equal [:bbq]
        end

      end

      describe '#sql' do

        describe 'with no columns' do

          it 'is the statement sql in parens preceded by <table> AS' do
            statement = Statement.new('zomg', :bbq)
            cte = CTE.new(:table, statement)
            cte.sql.must_equal '"table" AS (zomg)'
          end

        end

        describe 'with columns' do

          it 'includes the column list' do
            statement = Statement.new('zomg', :bbq)
            cte = CTE.new(:table, statement, columns: [:id, :name])
            cte.sql.must_equal '"table"("id", "name") AS (zomg)'
          end

        end

      end

    end
  end
end
