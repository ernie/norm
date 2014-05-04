require 'spec_helper'

module Norm
  module SQL
    describe OffsetClause do
      subject { OffsetClause.new.tap { |c| c.value = Fragment.new('$?', 1) } }

      it 'prefixes the fragment SQL with OFFSET' do
        subject.sql.must_equal 'OFFSET $?'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end
