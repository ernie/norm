require 'spec_helper'

module Norm
  module SQL
    describe ValueClause do
      subject { ValueClause.new }

      it 'is initially empty' do
        subject.must_be :empty?
      end

      it 'sets a value fragment with #value=' do
        subject.value = 'a fragment'
        subject.wont_be :empty?
      end

      describe 'with a value' do
        subject { ValueClause.new.tap { |clause|
          clause.value = Fragment.new('$?', 1)
        } }

        it 'contains the fragment SQL' do
          subject.sql.must_equal '$?'
        end

        it 'contains the fragment params' do
          subject.params.must_equal [1]
        end

      end

    end
  end
end
