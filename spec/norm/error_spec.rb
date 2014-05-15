require 'spec_helper'

module Norm

  describe Error do

    it 'is a StandardError' do
      Error.new.must_be_kind_of StandardError
    end

  end

  describe ConnectionResetError do

    it 'is an Error' do
      ConnectionResetError.new.must_be_kind_of Error
    end

  end

end
