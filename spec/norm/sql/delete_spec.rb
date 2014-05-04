require 'spec_helper'

module Norm
  module SQL
    describe Delete do

      it 'defaults to empty' do
        Delete.new.sql.must_equal ''
      end

      it 'allows specification of a custom SQL fragment to DELETE FROM on init' do
        Delete.new('people').sql.must_equal 'DELETE FROM people'
      end

      describe '#delete!' do

        it 'replaces the existing DELETE FROM clause of the statement' do
          delete = Delete.new('people')
          delete.delete!('customers')
          delete.sql.must_equal 'DELETE FROM customers'
        end

      end

      describe '#delete' do

        it 'returns a new statement with a different DELETE FROM clause' do
          delete = Delete.new('people')
          another_delete = delete.delete('customers')
          delete.sql.must_equal 'DELETE FROM people'
          another_delete.sql.must_equal 'DELETE FROM customers'
        end

      end

      describe '#using!' do

        it 'appends to the USING clause of the existing statement' do
          delete = Delete.new
          delete.using!('zomg')
          delete.sql.must_equal 'USING zomg'
        end

      end

      describe '#using' do

        it 'returns a new statement with appended USING clause' do
          delete = Delete.new
          another_delete = delete.using('zomg')
          delete.sql.must_equal ''
          another_delete.sql.must_equal 'USING zomg'
        end

      end

      describe '#where!' do

        it 'appends to the WHERE clause of the existing statement' do
          delete = Delete.new
          delete.where!('id is null')
          delete.sql.must_equal 'WHERE id is null'
        end

        it 'builds conditions from a hash' do
          delete = Delete.new
          delete.where!(:id => nil, :name => 'Ernie')
          delete.sql.must_equal(
            'WHERE "id" IS NULL AND "name" = $?'
          )
          delete.params.must_equal ['Ernie']
        end

      end

      describe '#where' do

        it 'returns a new statement with an appended WHERE clause' do
          delete = Delete.new
          another_delete = delete.where('id is null')
          delete.sql.must_equal ''
          another_delete.sql.must_equal 'WHERE id is null'
        end

        it 'builds conditions from a hash' do
          delete = Delete.new
          another_delete = delete.where(:id => nil, :name => 'Ernie')
          delete.sql.must_equal ''
          delete.params.must_equal []
          another_delete.sql.must_equal(
            'WHERE "id" IS NULL AND "name" = $?'
          )
          another_delete.params.must_equal ['Ernie']
        end

      end

      describe '#returning!' do

        it 'replaces the RETURNING clause with the given fragment' do
          delete = Delete.new
          delete.returning!('id, name, $? as one', 1)
          delete.returning!('id, name, $? as two', 2)
          delete.sql.must_equal 'RETURNING id, name, $? as two'
          delete.params.must_equal [2]
        end

      end

      describe '#returning' do

        it 'returns a new statement with a different returning clause' do
          delete = Delete.new
          delete.returning!('id, name, $? as one', 1)
          another_delete = delete.returning('id, name, $? as two', 2)
          delete.sql.must_equal 'RETURNING id, name, $? as one'
          delete.params.must_equal [1]
          another_delete.sql.must_equal 'RETURNING id, name, $? as two'
          another_delete.params.must_equal [2]
        end

      end

    end
  end
end
