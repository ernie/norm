require 'spec_helper'

module Norm
  module SQL
    describe Insert do

      it 'defaults to an empty INSERT' do
        Insert.new.sql.must_equal ''
      end

      it 'allows specification of table and column(s) on init' do
        Insert.new(:people, [:id, :name]).sql.
          must_equal 'INSERT INTO "people" ("id", "name")'
      end

      describe '#with!' do

        it 'appends to the existing statement WITH clause' do
          insert = Insert.new(:stmt)
          insert.with!(:stmt, Insert.new(:foo))
          insert.sql.must_equal(
            "WITH \"stmt\" AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

        it 'supports specifying column names' do
          insert = Insert.new(:stmt)
          insert.with!(:stmt, Insert.new(:foo), columns: [:bar])
          insert.sql.must_equal(
            "WITH \"stmt\"(\"bar\") AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

        it 'supports recursion' do
          insert = Insert.new(:stmt)
          insert.with!(:stmt, Insert.new(:foo), recursive: true)
          insert.sql.must_equal(
            "WITH RECURSIVE \"stmt\" AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

      end

      describe '#with' do

        it 'returns a new statement with appended WITH clause' do
          insert = Insert.new(:stmt)
          another_insert = insert.with(:stmt, Insert.new(:foo))
          insert.sql.must_equal 'INSERT INTO "stmt"'
          another_insert.sql.must_equal(
            "WITH \"stmt\" AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

        it 'supports specifying column names' do
          insert = Insert.new(:stmt)
          another_insert = insert.with(:stmt, Insert.new(:foo), columns: [:bar])
          insert.sql.must_equal 'INSERT INTO "stmt"'
          another_insert.sql.must_equal(
            "WITH \"stmt\"(\"bar\") AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

        it 'supports recursion' do
          insert = Insert.new(:stmt)
          another_insert = insert.with(:stmt, Insert.new(:foo), recursive: true)
          insert.sql.must_equal 'INSERT INTO "stmt"'
          another_insert.sql.must_equal(
            "WITH RECURSIVE \"stmt\" AS (INSERT INTO \"foo\")\nINSERT INTO \"stmt\""
          )
        end

      end

      describe '#insert!' do

        it 'replaces the INSERT clause of the statement' do
          insert = Insert.new(:people, :name)
          insert.insert!(:customers, :name)
          insert.sql.must_equal 'INSERT INTO "customers" ("name")'
        end

        it 'does not require columns' do
          insert = Insert.new(:people)
          insert.insert!(:customers)
          insert.sql.must_equal 'INSERT INTO "customers"'
        end

      end

      describe '#insert' do

        it 'returns a new statement with a different INSERT clause' do
          insert = Insert.new(:people, :name)
          another_insert = insert.insert(:customers, :name)
          insert.sql.must_equal 'INSERT INTO "people" ("name")'
          another_insert.sql.must_equal 'INSERT INTO "customers" ("name")'
        end

      end

      describe '#insert_sql!' do

        it 'replaces the INSERT clause of the statement' do
          insert = Insert.new(:people, :name)
          insert.insert_sql!('customers (name)')
          insert.sql.must_equal 'INSERT INTO customers (name)'
        end

      end

      describe '#insert_sql' do

        it 'returns a new statement with a different INSERT clause' do
          insert = Insert.new.insert_sql!('people (name)')
          another_insert = insert.insert_sql('customers (name)')
          insert.sql.must_equal 'INSERT INTO people (name)'
          another_insert.sql.must_equal 'INSERT INTO customers (name)'
        end

      end

      describe '#values!' do

        it 'appends a list of params to the existing VALUES clause' do
          insert = Insert.new
          insert.values!(1, 2)
          insert.sql.must_equal 'VALUES ($?, $?)'
          insert.params.must_equal [1, 2]
        end

      end

      describe '#values' do

        it 'returns a new statement with an additional param list in VALUES' do
          insert = Insert.new
          insert.values!(1, 2)
          another_insert = insert.values(3, 4)
          insert.sql.must_equal 'VALUES ($?, $?)'
          insert.params.must_equal [1, 2]
          another_insert.sql.must_equal 'VALUES ($?, $?), ($?, $?)'
          another_insert.params.must_equal [1, 2, 3, 4]
        end

      end

      describe '#values_sql!' do

        it 'appends a custom fragment to the existing VALUES clause' do
          insert = Insert.new
          insert.values_sql!('DEFAULT, $?', 'Ernie')
          insert.sql.must_equal 'VALUES (DEFAULT, $?)'
          insert.params.must_equal ['Ernie']
        end

      end

      describe '#values_sql' do

        it 'returns a new statement with additional custom VALUES fragment' do
          insert = Insert.new
          insert.values_sql!('DEFAULT, $?', 'Ernie')
          another_insert = insert.values_sql('DEFAULT, $?', 'Bert')
          insert.sql.must_equal 'VALUES (DEFAULT, $?)'
          insert.params.must_equal ['Ernie']
          another_insert.sql.must_equal 'VALUES (DEFAULT, $?), (DEFAULT, $?)'
          another_insert.params.must_equal ['Ernie', 'Bert']
        end

      end

      describe '#returning!' do

        it 'replaces the RETURNING clause with the given fragment' do
          insert = Insert.new
          insert.returning!('id, name, $? as one', 1)
          insert.returning!('id, name, $? as two', 2)
          insert.sql.must_equal 'RETURNING id, name, $? as two'
          insert.params.must_equal [2]
        end

      end

      describe '#returning' do

        it 'returns a new statement with a different returning clause' do
          insert = Insert.new
          insert.returning!('id, name, $? as one', 1)
          another_insert = insert.returning('id, name, $? as two', 2)
          insert.sql.must_equal 'RETURNING id, name, $? as one'
          insert.params.must_equal [1]
          another_insert.sql.must_equal 'RETURNING id, name, $? as two'
          another_insert.params.must_equal [2]
        end

      end

    end
  end
end
