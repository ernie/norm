require 'spec_helper'

module Norm
  module Attribute
    describe Interval do

      describe 'loading' do
        subject { Interval }

        it 'loads a String with explicit parts' do
          subject.load('1 year 2 months 3 days 4 hours 5 minutes 6.7 seconds').
            must_equal(
              Interval.new(1, 2, 3, Rational(147067, 10))
            )
        end

        it 'loads a String with explicit years, month, days and H:M:S' do
          subject.load('1 year 2 months 3 days 04:05:6.7').must_equal(
            Interval.new(1, 2, 3, Rational(147067, 10))
          )
        end

        it 'loads a String with explicit years, month, days and M:S' do
          subject.load('1 year 2 months 3 days 04:05.6').must_equal(
            Interval.new(1, 2, 3, Rational(2456, 10))
          )
        end

        it 'loads a String with explicit years, month, days and S' do
          subject.load('1 year 2 months 3 days 4').must_equal(
            Interval.new(1, 2, 3, 4)
          )
        end

      end

      describe 'loaded object' do

        it 'casts to String with positive seconds' do
          interval = Interval.load '1 year 2 months 3 days 04:05:06.7'
          interval.to_s.must_equal(
            '1 year 2 months 3 days 04:05:06.700000'
          )
        end

        it 'casts to String with negative seconds' do
          interval = Interval.load '1 year 2 months 3 days -04:05:06.7'
          interval.to_s.must_equal(
            '1 year 2 months 3 days -04:05:06.700000'
          )
        end

        it 'casts to String with only hours and smaller' do
          interval = Interval.load '300:01:02.345678'
          interval.to_s.must_equal '300:01:02.345678'
        end

        it 'casts to String with only hours and smaller' do
          interval = Interval.load '300:01:02.345678'
          interval.to_s.must_equal '300:01:02.345678'
        end

        it 'casts to String with no hours or smaller' do
          interval = Interval.load '1 day'
          interval.to_s.must_equal '1 day'
        end

        it 'converts partial years to months' do
          interval = Interval.load '1.5 years'
          interval.to_s.must_equal '1 year 6 months'
        end

        it 'converts partial days to hours' do
          interval = Interval.load '1.5 days'
          interval.to_s.must_equal '1 day 12:00:00.000000'
        end

        it 'converts extra months to years' do
          interval = Interval.load '1 year 12 months'
          interval.to_s.must_equal '2 years'
        end

        it 'subtracts parts' do
          interval = Interval.load '1 year -6.5 months'
          interval.to_s.must_equal '6 months -15 days'
        end

        it 'subtracts parts down to seconds' do
          interval = Interval.load '1 year -6.223 months'
          interval.to_s.must_equal '6 months -6 days -16:33:36.000000'
        end

        it 'subtracts parts down to fractional seconds' do
          interval = Interval.load '1 year -6.2234444 months'
          interval.to_s.must_equal '6 months -6 days -16:52:47.884800'
        end

        it 'subtracts parts down to *really small* fractional seconds' do
          interval = Interval.load '1 year -6.223444344 months'
          interval.to_s.must_equal '6 months -6 days -16:52:47.739648'
        end

        it 'returns 00:00:00.000000 if empty' do
          Interval.new(0, 0, 0, 0).to_s.must_equal '00:00:00.000000'
        end

        it 'casts to seconds with #to_r' do
          Interval.new(1, 2, 3, 4.5).to_r.must_equal(
            Rational(370008045, 10)
          )
        end

        it 'casts to whole seconds with #to_i' do
          Interval.new(1, 2, 3, 4.5).to_i.must_equal 37000804
        end

        it 'casts to float with #to_f' do
          Interval.new(1, 2, 3, 4.5).to_f.must_equal 37000804.5
        end

        it 'allows comparison with other intervals' do
          smaller = Interval.new(1, 2, 3, 4.5)
          larger  = Interval.new(1, 2, 3, 4.6)
          smaller.must_be :<, larger
        end

        it 'allows comparison with numerics by converting to seconds' do
          interval = Interval.new(1, 2, 3, 4.5)
          interval.must_be :<, 37000805
          interval.must_be :>, 37000804
        end

      end

      describe 'Interval()' do

        it 'returns Interval' do
          Attribute::Interval().must_be_same_as Interval
        end

      end

    end
  end
end
