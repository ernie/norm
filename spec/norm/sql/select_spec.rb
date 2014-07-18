require 'spec_helper'

module Norm
  module SQL
    describe Select do

      it 'defaults to selecting *' do
        Select.new.sql.must_equal 'SELECT *'
      end

      it 'allows specification of a custom SQL fragment to select on init' do
        Select.new('"id", "name"').sql.must_equal 'SELECT "id", "name"'
      end

      describe '#with!' do

        it 'appends to the existing statement WITH clause' do
          select = Select.new
          select.with!(:stmt, Select.new(:foo))
          select.sql.must_equal "WITH \"stmt\" AS (SELECT \"foo\")\nSELECT *"
        end

        it 'supports specifying column names' do
          select = Select.new
          select.with!(:stmt, Select.new(:foo), columns: [:bar])
          select.sql.must_equal(
            "WITH \"stmt\"(\"bar\") AS (SELECT \"foo\")\nSELECT *"
          )
        end

      end

      describe '#with' do

        it 'returns a new statement with appended WITH clause' do
          select = Select.new
          another_select = select.with(:stmt, Select.new(:foo))
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal(
            "WITH \"stmt\" AS (SELECT \"foo\")\nSELECT *"
          )
        end

        it 'supports specifying column names' do
          select = Select.new
          another_select = select.with(:stmt, Select.new(:foo), columns: [:bar])
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal(
            "WITH \"stmt\"(\"bar\") AS (SELECT \"foo\")\nSELECT *"
          )
        end

      end

      describe '#select!' do

        it 'appends to the existing statement SELECT clause' do
          select = Select.new('"id"')
          select.select!('"name"')
          select.sql.must_equal 'SELECT "id", "name"'
        end

      end

      describe '#select' do

        it 'returns a new statment with appended SELECT clause' do
          select = Select.new('"id"')
          another_select = select.select('"name"')
          select.sql.must_equal 'SELECT "id"'
          another_select.sql.must_equal 'SELECT "id", "name"'
        end

      end

      describe '#from!' do

        it 'appends to the FROM clause of the existing statement' do
          select = Select.new
          select.from!('zomg')
          select.sql.must_equal "SELECT *\nFROM zomg"
        end

      end

      describe '#from' do

        it 'returns a new statement with appended FROM clause' do
          select = Select.new
          another_select = select.from('zomg')
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal "SELECT *\nFROM zomg"
        end

      end

      describe '#where!' do

        it 'appends to the WHERE clause of the existing statement' do
          select = Select.new
          select.where!('id is null')
          select.sql.must_equal "SELECT *\nWHERE id is null"
        end

        it 'builds conditions from a hash' do
          select = Select.new
          select.where!(:id => nil, :name => 'Ernie')
          select.sql.must_equal(
            "SELECT *\nWHERE \"id\" IS NULL AND \"name\" = $?"
          )
          select.params.must_equal ['Ernie']
        end

      end

      describe '#where' do

        it 'returns a new statement with an appended WHERE clause' do
          select = Select.new
          another_select = select.where('id is null')
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal "SELECT *\nWHERE id is null"
        end

        it 'builds conditions from a hash' do
          select = Select.new
          another_select = select.where(:id => nil, :name => 'Ernie')
          select.sql.must_equal 'SELECT *'
          select.params.must_equal []
          another_select.sql.must_equal(
            "SELECT *\nWHERE \"id\" IS NULL AND \"name\" = $?"
          )
          another_select.params.must_equal ['Ernie']
        end

      end

      describe '#group!' do

        it 'appends to the GROUP BY clause of the existing statement' do
          select = Select.new
          select.group!('id')
          select.sql.must_equal "SELECT *\nGROUP BY id"
        end

      end

      describe '#group' do

        it 'returns a new statement with an appended GROUP BY clause' do
          select = Select.new
          another_select = select.group('id')
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal "SELECT *\nGROUP BY id"
        end

      end

      describe '#having!' do

        it 'appends to the HAVING clause of the existing statement' do
          select = Select.new
          select.having!('id is null')
          select.sql.must_equal "SELECT *\nHAVING id is null"
        end

        it 'builds conditions from a hash' do
          select = Select.new
          select.having!(:id => nil, :name => 'Ernie')
          select.sql.must_equal(
            "SELECT *\nHAVING \"id\" IS NULL AND \"name\" = $?"
          )
          select.params.must_equal ['Ernie']
        end
      end

      describe '#having' do

        it 'returns a new statement with an appended HAVING clause' do
          select = Select.new
          another_select = select.having('id is null')
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal "SELECT *\nHAVING id is null"
        end

        it 'builds conditions from a hash' do
          select = Select.new
          another_select = select.having(:id => nil, :name => 'Ernie')
          select.sql.must_equal 'SELECT *'
          select.params.must_equal []
          another_select.sql.must_equal(
            "SELECT *\nHAVING \"id\" IS NULL AND \"name\" = $?"
          )
          another_select.params.must_equal ['Ernie']
        end
      end

      describe '#order!' do

        it 'appends to the ORDER BY clause of the existing statement' do
          select = Select.new
          select.order!('id')
          select.sql.must_equal "SELECT *\nORDER BY id"
        end

      end

      describe '#order' do

        it 'returns a new statement with an appended ORDER BY clause' do
          select = Select.new
          another_select = select.order('id')
          select.sql.must_equal 'SELECT *'
          another_select.sql.must_equal "SELECT *\nORDER BY id"
        end

      end

      describe '#limit!' do

        it 'sets the LIMIT clause of the existing statement' do
          select = Select.new
          select.limit!('5')
          select.sql.must_equal "SELECT *\nLIMIT 5"
        end

      end

      describe '#limit' do

        it 'returns a new statement with a different LIMIT clause' do
          select = Select.new.limit!('5')
          another_select = select.limit('6')
          select.sql.must_equal "SELECT *\nLIMIT 5"
          another_select.sql.must_equal "SELECT *\nLIMIT 6"
        end

      end

      describe '#offset!' do

        it 'sets the OFFSET clause of the existing statement' do
          select = Select.new
          select.offset!('5')
          select.sql.must_equal "SELECT *\nOFFSET 5"
        end

      end

      describe '#offset' do

        it 'returns a new statement with a different OFFSET clause' do
          select = Select.new.offset!('5')
          another_select = select.offset('6')
          select.sql.must_equal "SELECT *\nOFFSET 5"
          another_select.sql.must_equal "SELECT *\nOFFSET 6"
        end

      end

    end
  end
end
