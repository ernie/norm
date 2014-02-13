require 'spec_helper'

module Norm
  module Attribute
    module Parsing
      describe Interval do

        it 'parses with explicit parts' do
          interval = Interval.new(
            '1 year 2 months 3 days 4 hours 5 minutes 6.7 seconds'
          )
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 14706.7
        end

        it 'parses with explicit years, month, days and H:M:S.s' do
          interval = Interval.new('1 year 2 months 3 days 04:05:6.7')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 14706.7
        end

        it 'parses with explicit years, month, days and M:S.s' do
          interval = Interval.new('1 year 2 months 3 days 04:05.6')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 245.6
        end

        it 'parses with explicit years, month, days and H:M' do
          interval = Interval.new('1 year 2 months 3 days 04:05')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 14700
        end

        it 'parses with explicit years, month, days and S' do
          interval = Interval.new('1 year 2 months 3 days 4')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 4
        end

        it 'parses with negative explicit values' do
          interval = Interval.new(
            '-1 year -2 months -3 days -4 hours -5 minutes -6 seconds'
          )
          interval.years.must_equal -1
          interval.months.must_equal -2
          interval.days.must_equal -3
          interval.seconds.must_equal -14706
        end

        it 'parses with negative segmented values' do
          interval = Interval.new('-01:02:03.4')
          interval.years.must_equal 0
          interval.months.must_equal 0
          interval.days.must_equal 0
          interval.seconds.must_equal -3723.4
        end

        it 'raises an ArgumentError if conflicting hours/minutes given' do
          proc { Interval.new('1 year 2 months 3 days 4 hours 04:00:00') }.
            must_raise ArgumentError
          proc { Interval.new('1 year 2 months 3 days 4 hours 00:00.1') }.
            must_raise ArgumentError
        end

        it 'raises an ArgumentError if conflicting seconds given' do
          proc { Interval.new('1 year 2 months 3 days 4 seconds 5') }.
            must_raise ArgumentError
        end

        it 'discards all segments if negative segments are supplied' do
          interval = Interval.new('1 year 2 months 3 days 01:-02:03')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 0
        end

        it 'discards all segments if segment starts with a colon' do
          interval = Interval.new('1 year 2 months 3 days :01:02')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 0
        end

        it 'discards all segments if segment starts with a minus-colon' do
          interval = Interval.new('1 year 2 months 3 days -:01:02')
          interval.years.must_equal 1
          interval.months.must_equal 2
          interval.days.must_equal 3
          interval.seconds.must_equal 0
        end

        it 'raises an ArgumentError if only negative segments are supplied' do
          proc { Interval.new('-01:-02:03') }.must_raise ArgumentError
        end

      end
    end
  end
end
