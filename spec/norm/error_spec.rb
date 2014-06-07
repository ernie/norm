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

  describe NotFoundError do

    it 'is an Error' do
      NotFoundError.new.must_be_kind_of Error
    end

  end

  describe ResultMismatchError do

    it 'is an Error' do
      ResultMismatchError.new.must_be_kind_of Error
    end

  end

end
