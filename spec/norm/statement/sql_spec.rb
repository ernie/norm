require 'spec_helper'

module Norm
  module Statement
    describe SQL do
      subject { SQL }

      it 'defaults to empty sql' do
        subject.new.sql.must_equal ''
      end

      it 'defaults to empty params' do
        subject.new.params.must_equal []
      end

      it 'allows specification of custom SQL' do
        subject.new('select 1').sql.must_equal 'select 1'
      end

      it 'allows specification of custom params' do
        subject.new('', 'zomg').params.must_equal(['zomg'])
      end

      it 'allows interpolation of hash params' do
        statement = subject.new('$foo', :foo => 'bar')
        statement.sql.must_equal '$?'
        statement.params.must_equal ['bar']
      end

      it 'allows interpolation of nested hash params' do
        statement = subject.new(
          '$foo.bar.baz', :foo => {:bar => {:baz => 'qux'}}
        )
        statement.sql.must_equal '$?'
        statement.params.must_equal ['qux']
      end

      it 'allows escaping of interpolation with backslash' do
        statement = subject.new('\\$foo', {})
        statement.sql.must_equal '$foo'
        statement.params.must_equal []
      end

    end
  end
end
