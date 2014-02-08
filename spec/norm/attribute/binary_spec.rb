require 'spec_helper'

module Norm
  module Attribute
    describe Binary do

      describe 'loading' do
        subject { Binary }

        it 'returns a binary containing data of object.to_s' do
          binary = subject.load(42)
          binary.data.must_equal '42'
        end

        it 'unescapes PostgreSQL "hex" encoded strings' do
          subject.load('\xdeadbeef').data.must_equal(
            [0xde, 0xad, 0xbe, 0xef].pack('c*')
          )
        end

      end

      describe 'loaded object' do
        subject { Binary.load('\xdeadbeef') }

        it 'casts to string with PostgreSQL "hex" encoding' do
          subject.to_s.must_equal '\xdeadbeef'
        end
      end

    end
  end
end
