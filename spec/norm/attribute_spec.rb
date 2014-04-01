require 'spec_helper'

module Norm
  describe Attribute do

    it 'is aliased to Attr' do
      Attr.must_equal Attribute
    end

  end
end
