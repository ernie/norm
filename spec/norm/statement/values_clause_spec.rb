require 'spec_helper'

module Norm
  module Statement
    describe ValuesClause do
      subject { ValuesClause.new }

      it 'wraps fragments in a grouping' do
        subject << Fragment.new('$?, $?, $?', 1, 2, 3)
        subject.sql.must_equal 'VALUES ($?, $?, $?)'
        subject.params.must_equal [1, 2, 3]
      end

      it 'joins multiple fragments with commas' do
        subject << Fragment.new('$?, $?, $?', 1, 2, 3)
        subject << Fragment.new('$?, $?, $?', 4, 5, 6)
        subject.sql.must_equal 'VALUES ($?, $?, $?), ($?, $?, $?)'
        subject.params.must_equal [1, 2, 3, 4, 5, 6]
      end

    end
  end
end
