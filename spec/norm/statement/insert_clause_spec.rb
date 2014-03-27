require 'spec_helper'

module Norm
  module Statement
    describe InsertClause do

      it 'requires a table name' do
        proc { InsertClause.new }.must_raise ArgumentError
      end

      describe 'with only a table name' do
        subject { InsertClause.new(:people) }

        it 'quotes a table name as identifier' do
          subject.sql.must_equal 'INSERT INTO "people"'
        end

        it 'has empty params' do
          subject.params.must_equal []
        end

      end

      describe 'with a table name and specified columns' do
        subject { InsertClause.new(:people, :id, :name, :age) }

        it 'includes the columns in the SQL' do
          subject.sql.must_equal 'INSERT INTO "people" ("id", "name", "age")'
        end
      end

    end
  end
end
