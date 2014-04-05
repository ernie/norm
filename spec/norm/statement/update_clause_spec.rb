require 'spec_helper'

module Norm
  module Statement
    describe UpdateClause do
      subject {
        UpdateClause.new.tap { |c| c.value = Fragment.new('people', 1) }
      }

      it 'prefixes the fragment SQL with UPDATE' do
        subject.sql.must_equal 'UPDATE people'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end
