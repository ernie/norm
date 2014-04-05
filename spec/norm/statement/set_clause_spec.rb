require 'spec_helper'

module Norm
  module Statement
    describe SetClause do
      subject {
        SetClause.new.tap { |c| c << Fragment.new('name = $?', 'Ernie') }
      }

      it 'prefixes the fragment SQL with SET' do
        subject.sql.must_equal 'SET name = $?'
      end

      it 'contains the fragment params' do
        subject.params.must_equal ['Ernie']
      end

    end
  end
end
