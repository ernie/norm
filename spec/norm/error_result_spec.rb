require 'spec_helper'

module Norm
  describe ErrorResult do
    subject { ErrorResult.new }

    it 'is not successful' do
      subject.wont_be :success?
    end

    it 'is error' do
      subject.must_be :error?
    end

  end
end
