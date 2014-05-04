require 'spec_helper'

module Norm
  module SQL
    describe LimitClause do
      subject { LimitClause.new.tap { |c| c.value = Fragment.new('$?', 1) } }

      it 'prefixes the fragment SQL with LIMIT' do
        subject.sql.must_equal 'LIMIT $?'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end
