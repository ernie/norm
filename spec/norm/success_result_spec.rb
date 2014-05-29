require 'spec_helper'

module Norm
  describe SuccessResult do
    subject { SuccessResult.new }

    it 'is successful' do
      subject.must_be :success?
    end

    it 'is not error' do
      subject.wont_be :error?
    end

  end
end
