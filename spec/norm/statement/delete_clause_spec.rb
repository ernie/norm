require 'spec_helper'

module Norm
  module Statement
    describe DeleteClause do
      subject {
        DeleteClause.new.tap { |c| c.value = Fragment.new('people', 1) }
      }

      it 'prefixes the fragment SQL with DELETE FROM' do
        subject.sql.must_equal 'DELETE FROM people'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end
