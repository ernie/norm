require 'spec_helper'

module Norm
  module Statement
    describe Fragment do
      subject { Fragment }

      it 'defaults to empty sql' do
        subject.new.sql.must_equal ''
      end

      it 'defaults to empty params' do
        subject.new.params.must_equal []
      end

      it 'allows specification of custom SQL' do
        subject.new('select 1').sql.must_equal 'select 1'
      end

      it 'casts sql param to string' do
        subject.new(1).sql.must_equal '1'
      end

      it 'allows specification of custom params' do
        subject.new('', 'zomg').params.must_equal(['zomg'])
      end

      it 'allows interpolation of hash params' do
        fragment = subject.new('$foo', :foo => 'bar')
        fragment.sql.must_equal '$?'
        fragment.params.must_equal ['bar']
      end

      it 'allows interpolation of nested hash params' do
        fragment = subject.new(
          '$foo.bar.baz', :foo => {:bar => {:baz => 'qux'}}
        )
        fragment.sql.must_equal '$?'
        fragment.params.must_equal ['qux']
      end

      it 'raises MissingInterpolationError if a missing key is referenced' do
        error = proc { subject.new('$foo.bar', :foo => {}) }.must_raise(
          MissingInterpolationError
        )
        error.message.must_equal 'Missing content for "foo.bar".'
      end

      it 'allows escaping of interpolation with backslash' do
        fragment = subject.new('\\$foo', {})
        fragment.sql.must_equal '$foo'
        fragment.params.must_equal []
      end

    end
  end
end
