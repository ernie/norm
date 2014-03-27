require 'spec_helper'

module Norm
  module Statement
    describe Grouping do

      it 'wraps a fragment in parentheses' do
        grouping = Grouping.new(Fragment.new('zomg', 1))
        grouping.sql.must_equal '(zomg)'
        grouping.params.must_equal [1]
      end

      it 'delegates to the fragment' do
        select = SelectClause.new
        grouping = Grouping.new(select)
        grouping << Fragment.new('zomg')
        grouping.sql.must_equal '(SELECT zomg)'
      end

      it 'responds to things the fragment responds to' do
        select = SelectClause.new
        grouping = Grouping.new(select)
        grouping.must_respond_to :<<
      end

    end
  end
end
