require 'spec_helper'

module Norm
  module Statement
    describe Update do

      it 'defaults to empty' do
        Update.new.sql.must_equal ''
      end

      it 'allows specification of a custom SQL fragment to UPDATE on init' do
        Update.new('people').sql.must_equal 'UPDATE people'
      end

      describe '#update!' do

        it 'replaces the existing UPDATE clause of the statement' do
          update = Update.new('people')
          update.update!('customers')
          update.sql.must_equal 'UPDATE customers'
        end

      end

      describe '#update' do

        it 'returns a new statement with a different UPDATE clause' do
          update = Update.new('people')
          another_update = update.update('customers')
          update.sql.must_equal 'UPDATE people'
          another_update.sql.must_equal 'UPDATE customers'
        end

      end

      describe '#set!' do

        it 'appends to the existing statement SET clause' do
          update = Update.new
          update.set!('name = $?', 'Ernie')
          update.sql.must_equal 'SET name = $?'
          update.params.must_equal ['Ernie']
        end

        it 'sets from a hash' do
          update = Update.new
          update.set!(:name => 'Ernie', :age => nil)
          update.sql.must_equal 'SET "name" = $?, "age" = NULL'
          update.params.must_equal ['Ernie']
        end

      end

      describe '#set' do

        it 'returns a new statment with appended SET clause' do
          update = Update.new
          update.set!('name = $?', 'Ernie')
          another_update = update.set('age = $?', 36)
          update.sql.must_equal 'SET name = $?'
          update.params.must_equal ['Ernie']
          another_update.sql.must_equal 'SET name = $?, age = $?'
          another_update.params.must_equal ['Ernie', 36]
        end

        it 'sets from a hash' do
          update = Update.new
          update.set!(:name => 'Ernie')
          another_update = update.set(:age => 36)
          update.sql.must_equal 'SET "name" = $?'
          update.params.must_equal ['Ernie']
          another_update.sql.must_equal 'SET "name" = $?, "age" = $?'
          another_update.params.must_equal ['Ernie', 36]
        end

      end

      describe '#from!' do

        it 'appends to the FROM clause of the existing statement' do
          update = Update.new
          update.from!('zomg')
          update.sql.must_equal 'FROM zomg'
        end

      end

      describe '#from' do

        it 'returns a new statement with appended FROM clause' do
          update = Update.new
          another_update = update.from('zomg')
          update.sql.must_equal ''
          another_update.sql.must_equal 'FROM zomg'
        end

      end

      describe '#where!' do

        it 'appends to the WHERE clause of the existing statement' do
          update = Update.new
          update.where!('id is null')
          update.sql.must_equal 'WHERE id is null'
        end

        it 'builds conditions from a hash' do
          update = Update.new
          update.where!(:id => nil, :name => 'Ernie')
          update.sql.must_equal(
            'WHERE "id" IS NULL AND "name" = $?'
          )
          update.params.must_equal ['Ernie']
        end

      end

      describe '#where' do

        it 'returns a new statement with an appended WHERE clause' do
          update = Update.new
          another_update = update.where('id is null')
          update.sql.must_equal ''
          another_update.sql.must_equal 'WHERE id is null'
        end

        it 'builds conditions from a hash' do
          update = Update.new
          another_update = update.where(:id => nil, :name => 'Ernie')
          update.sql.must_equal ''
          update.params.must_equal []
          another_update.sql.must_equal(
            'WHERE "id" IS NULL AND "name" = $?'
          )
          another_update.params.must_equal ['Ernie']
        end

      end

      describe '#returning!' do

        it 'replaces the RETURNING clause with the given fragment' do
          update = Update.new
          update.returning!('id, name, $? as one', 1)
          update.returning!('id, name, $? as two', 2)
          update.sql.must_equal 'RETURNING id, name, $? as two'
          update.params.must_equal [2]
        end

      end

      describe '#returning' do

        it 'returns a new statement with a different returning clause' do
          update = Update.new
          update.returning!('id, name, $? as one', 1)
          another_update = update.returning('id, name, $? as two', 2)
          update.sql.must_equal 'RETURNING id, name, $? as one'
          update.params.must_equal [1]
          another_update.sql.must_equal 'RETURNING id, name, $? as two'
          another_update.params.must_equal [2]
        end

      end

    end
  end
end
