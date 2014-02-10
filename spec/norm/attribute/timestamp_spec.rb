require 'spec_helper'

module Norm
  module Attribute
    describe Timestamp do

      describe 'loading' do
        subject { Timestamp }

        it 'loads a String with no time zone as UTC' do
          timestamp = subject.load('2014-12-25 00:00:00')
          timestamp.must_equal(DateTime.new(2014, 12, 25, 0, 0, 0))
          timestamp.offset.must_equal 0
        end

        it 'rounds fractional seconds to microseconds' do
          timestamp = subject.load('2014-12-25 00:00:00.123456789')
          timestamp.sec_fraction.must_equal 0.123457
        end

        it 'loads a String with a named time zone as UTC' do
          timestamp = subject.load('2014-12-25 00:00:00 EST')
          timestamp.must_equal(DateTime.new(2014, 12, 25, 5, 0, 0))
          timestamp.offset.must_equal 0
        end

        it 'loads a String with a whole hour offset as UTC' do
          timestamp = subject.load('2014-12-25 00:00:00-5')
          timestamp.must_equal(DateTime.new(2014, 12, 25, 5, 0, 0))
          timestamp.offset.must_equal 0
        end

        it 'loads a String with a partial hour offset as UTC' do
          timestamp = subject.load('2014-12-25 00:00:00-530')
          timestamp.must_equal(DateTime.new(2014, 12, 25, 5, 30, 0))
          timestamp.offset.must_equal 0
        end

        it 'loads a Time with a UTC offset as UTC' do
          timestamp = subject.load(::Time.new(2014, 12, 25, 0, 0, 0, '-05:00'))
          timestamp.must_equal(DateTime.new(2014, 12, 25, 5, 0, 0))
          timestamp.offset.must_equal 0
        end

        it 'loads a Date in UTC' do
          timestamp = subject.load(::Date.new(2014, 12, 25))
          timestamp.must_equal(DateTime.new(2014, 12, 25, 0, 0, 0))
          timestamp.offset.must_equal 0
        end

        it 'loads a DateTime in UTC without changing the incoming object' do
          datetime = DateTime.new(2014, 12, 25, 0, 0, 0, '-5')
          timestamp = subject.load(datetime)
          timestamp.must_equal(datetime)
          datetime.offset.must_equal Rational(-5, 24)
          timestamp.offset.must_equal 0
        end

        it 'loads another Timestamp' do
          timestamp1 = subject.load('2014-12-25 00:00:00+0')
          timestamp2 = subject.load(timestamp1)
          timestamp2.wont_be_same_as timestamp1
          timestamp2.must_equal timestamp1
        end

      end

      describe 'loaded object' do

        it 'casts to string' do
          Timestamp.load('2014-12-25 00:00:00').to_s.must_equal(
            '2014-12-25 00:00:00.000000+0000'
          )
        end

      end

    end
  end
end
