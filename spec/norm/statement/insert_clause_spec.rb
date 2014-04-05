require 'spec_helper'

module Norm
  module Statement
    describe InsertClause do
      subject {
        InsertClause.new.tap { |c| c.value = Fragment.new('people', 1) }
      }

      it 'prefixes the fragment SQL with INSERT INTO' do
        subject.sql.must_equal 'INSERT INTO people'
      end

      it 'contains the fragment params' do
        subject.params.must_equal [1]
      end

    end
  end
end

