require 'spec_helper'

module Norm
  module Statement
    describe CollectionClause do
      subject { CollectionClause.new }

      it 'is initially empty' do
        subject.must_be :empty?
      end

      it 'appends fragments with <<' do
        subject << 'a fragment'
        subject.wont_be :empty?
      end

      describe 'with fragments' do
        subject { CollectionClause.new.tap { |clause|
          clause << Fragment.new('$?', 1)
          clause << Fragment.new('$?', 2)
        } }

        it 'contains joined fragment SQL' do
          subject.sql.must_equal '$? $?'
        end

        it 'contains combined fragment params' do
          subject.params.must_equal [1, 2]
        end

        it 'dups its fragments on dup' do
          clause1 = subject
          clause2 = clause1.dup
          clause1 << Fragment.new('$?', 3)
          clause2 << Fragment.new('$?', 4)
          clause1.params.must_equal [1, 2, 3]
          clause2.params.must_equal [1, 2, 4]
        end
      end

    end
  end
end
