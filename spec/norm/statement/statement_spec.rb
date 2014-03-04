require 'spec_helper'

module Norm
  module Statement
    describe Statement do
      subject { Statement }

      it 'defaults to empty sql' do
        subject.new.sql.must_equal ''
      end

      it 'defaults to empty params' do
        subject.new.params.must_equal []
      end

      it 'defaults to 0 result format' do
        subject.new.result_format.must_equal 0
      end

      it 'allows specification of custom SQL' do
        subject.new('select 1').sql.must_equal 'select 1'
      end

      it 'allows specification of custom params' do
        subject.new('', ['zomg']).params.must_equal(['zomg'])
      end

      it 'allows specification of custom result format' do
        subject.new('', [], 1).result_format.must_equal 1
      end

    end
  end
end
