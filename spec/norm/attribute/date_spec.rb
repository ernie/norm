require 'spec_helper'

module Norm
  module Attribute
    describe Date do

      describe 'loading' do
        subject { Date }

        it 'loads a String' do
          subject.load('2014-12-25').must_equal ::Date.new(2014, 12, 25)
        end

        it 'loads a Time' do
          subject.load(Time.parse('2014-12-25')).must_equal(
            ::Date.new(2014, 12, 25)
          )
        end

        it 'loads a DateTime' do
          subject.load(DateTime.parse('2014-12-25')).must_equal(
            ::Date.new(2014, 12, 25)
          )
        end

        it 'loads a Date' do
          date1 = ::Date.new(2014, 12, 25)
          date2 = subject.load(date1)
          date2.wont_be_same_as date1
          date2.must_equal date1
        end

      end

      describe 'loaded object' do
        subject { Date.load('2014-12-25') }

        it 'casts to string' do
          subject.to_s.must_equal '2014-12-25'
        end
      end

    end
  end
end
