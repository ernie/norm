require 'spec_helper'

module Norm
  module Statement
    describe Update do

      it 'requires a table name to update' do
        proc { Update.new }.must_raise ArgumentError
      end

    end
  end
end
