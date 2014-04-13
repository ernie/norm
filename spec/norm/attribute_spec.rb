require 'spec_helper'

module Norm
  describe Attribute do

    it 'is aliased to Attr' do
      Attr.must_equal Attribute
    end

    it 'provides a base Error for Attribute issues' do
      Attribute::Error.new.must_be_kind_of Norm::Error
    end

    it 'provides a LoadingError for issues with attribute loading' do
      Attribute::LoadingError.new.must_be_kind_of Attribute::Error
    end

  end
end
