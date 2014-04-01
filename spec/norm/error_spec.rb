require 'spec_helper'

module Norm

  describe Error do

    it 'is a StandardError' do
      Error.new.must_be_kind_of StandardError
    end

  end

end
