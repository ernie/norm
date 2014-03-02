require 'spec_helper'

module Norm
  module Statement
    describe Statement do
      subject { Statement }

      it 'defaults to empty sql' do
        subject.new.sql.must_equal ''
      end

      it 'defaults to empty params' do
        subject.new.params.must_equal Hash.new
      end

      it 'defaults to :text result format' do
        subject.new.result_format.must_equal :text
      end

      it 'allows specification of custom SQL' do
        subject.new('select 1').sql.must_equal 'select 1'
      end

      it 'allows specification of custom params' do
        subject.new('', :key => 'value').params.must_equal('key' => 'value')
      end

    end
  end
end
