require 'spec_helper'

module Norm
  module Attribute
    describe Identifier do

      describe 'initialization' do
        subject { Identifier }

        it 'treats symbols as full identifiers' do
          id = subject.new(:'crazy".."identifier!!')
          id.value.must_equal '"crazy""..""identifier!!"'
        end

        it 'treats strings as multiple identifiers separated by dots' do
          id = subject.new('people.id')
          id.value.must_equal '"people"."id"'
        end

      end

      subject { Identifier.new('people.id') }

      describe '#value' do

        it 'returns the quoted identifier' do
          subject.value.must_equal '"people"."id"'
        end

      end

      describe '#to_s' do

        it 'returns the quoted identifier' do
          subject.value.must_equal '"people"."id"'
        end

      end

      describe '#inspect' do

        it 'returns a readable representation of the identifier' do
          subject.inspect.must_equal(
            '#<Norm::Attribute::Identifier "people"."id">'
          )
        end

      end

      describe '#==' do

        it 'is true if the classes and values are identical' do
          other = Identifier.new('people.id')
          subject.must_equal other
        end

        it 'is true if the classes share ancestry and values are identical' do
          other = Class.new(Identifier).new('people.id')
          subject.must_equal other
        end

        it 'is false if the classes do not share ancestry' do
          other = Struct.new(:value).new('"people"."id"')
          subject.wont_equal other
        end

        it 'is false if the values are not equal' do
          other = Identifier.new('people.name')
          subject.wont_equal other
        end

      end

      describe '#eql?' do

        it 'is true if the classes and values are identical' do
          other = Identifier.new('people.id')
          subject.must_be :eql?, other
        end

        it 'is false if the classes share ancestry and values are identical' do
          other = Class.new(Identifier).new('people.id')
          subject.wont_be :eql?, other
        end

        it 'is false if the classes do not share ancestry' do
          other = Struct.new(:value).new('"people"."id"')
          subject.wont_be :eql?, other
        end

        it 'is false if the values are not equal' do
          other = Identifier.new('people.name')
          subject.wont_be :eql?,  other
        end

      end

      describe '#hash' do

        it 'equals another object based on class and value' do
          other = Identifier.new('people.id')
          subject.hash.must_equal other.hash
        end

      end

      describe 'Identifier()' do

        it 'instantiates Identifier via method' do
          id = Attribute::Identifier('people.id')
          id.must_be_kind_of Identifier
          id.value.must_equal '"people"."id"'
        end

      end

    end
  end
end
