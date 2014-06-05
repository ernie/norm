require 'spec_helper'

module Norm
  module Attribute
    describe Time do

      describe 'loading' do
        subject { Time }

        it 'loads a String' do
          Time.parse('11:00 PM').must_equal(
            Time.new(23, 0, 0, 0, 0)
          )
        end

        it 'loads a Ruby Time' do
          time = subject.load(::Time.new(2014, 12, 25, 0, 0, 0, '-05:00'))
          time.must_equal(Time.new(0, 0, 0, 0, -(5 * 3600)))
        end

        it 'loads a DateTime' do
          time = subject.load(DateTime.new(2014, 12, 25, 0, 0, 0, '-05:00'))
          time.must_equal(Time.new(0, 0, 0, 0, -(5 * 3600)))
        end
      end

      describe 'loaded object' do

        it 'casts to String with negative offset' do
          time = Time.parse('11:00:00.123456789 PM -0530')
          time.to_s.must_equal('23:00:00.123457-0530')
        end

        it 'casts to String with positive offset' do
          time = Time.parse('11:00:00.123456789 PM +0530')
          time.to_s.must_equal('23:00:00.123457+0530')
        end

        it 'casts to String with a small negative offset' do
          time = Time.parse('11:00:00.123456789 PM -0030')
          time.to_s.must_equal('23:00:00.123457-0030')
        end

      end

      describe 'Time()' do

        it 'returns Time' do
          Attribute::Time().must_be_same_as Time
        end

      end

    end
  end
end
