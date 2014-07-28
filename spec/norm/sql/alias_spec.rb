require 'spec_helper'

module Norm
  module SQL
    describe Alias do

      describe 'initialization' do
        subject { Alias }

        it 'requires a fragment and name' do
          proc { subject.new }.must_raise ArgumentError
          proc { subject.new :fragment }.must_raise ArgumentError
          (Alias === subject.new(:fragment, :symbol)).must_equal true
        end

      end

      let(:grouping) { Grouping.new(Statement.new("select $?", 'foo')) }
      subject {
        Alias.new(grouping, :foo)
      }

      describe '#fragment' do

        it 'returns the fragment supplied during initialization' do
          # BasicObject doesn't play nicely with MiniTest::Spec
          assert_same grouping, subject.fragment
        end

      end

      describe '#name' do

        it 'returns an identifier for the name given on initialization' do
          subject.name.to_s.must_equal '"foo"'
        end

      end

      describe '#sql' do

        it 'returns the fragment SQL with an alias' do
          subject.sql.must_equal '(select $?) AS "foo"'
        end

      end

      describe '#params' do

        it 'returns the fragment params' do
          subject.params.must_equal ['foo']
        end

      end

      describe '#as' do

        it 'returns a new renamed alias' do
          new_alias = subject.as(:zomg)
          subject.sql.must_equal '(select $?) AS "foo"'
          new_alias.sql.must_equal '(select $?) AS "zomg"'
        end

      end

    end
  end
end
