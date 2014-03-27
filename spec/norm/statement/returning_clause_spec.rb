require 'spec_helper'

module Norm
  module Statement
    describe ReturningClause do
      subject {
        ReturningClause.new.tap { |c| c.value = Fragment.new('a, $? AS b', 1) }
      }

      it 'prefixes the fragment SQL with RETURNING' do
        subject.sql.must_equal 'RETURNING a, $? AS b'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end
