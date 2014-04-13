require 'spec_helper'

module Norm
  module Attribute
    describe Delegator do
      let(:delegate) { Minitest::Mock.new }
      subject { Delegator.new(delegate, :some, :params, :here) }

      it 'passes its args to the delegate' do
        delegate.expect(:load, 'loaded', ['object', :some, :params, :here])
        subject.load('object')
        delegate.verify
      end

      it 'passes additional args to load after its own args' do
        delegate.expect(:load, 'loaded', ['object', :some, :params, :here, 1])
        subject.load('object', 1)
        delegate.verify
      end

    end
  end
end
