require 'date'

module Norm
  module Attribute
    class Time
      extend Loading

      attr_reader :hour, :min, :sec, :fraction, :offset

      def initialize(hour = 0, min = 0, sec = 0, fraction = 0, offset = 0)
        @hour, @min, @sec, @fraction, @offset =
          hour.to_i, min.to_i, sec.to_i, fraction.to_r.round(6), offset
      end

      def offset_hours
        (offset / 3600.0).to_i
      end

      def offset_minutes
        divisor = offset_hours * 3600
        divisor = @offset < 0 ? -3600 : 3600 if divisor.zero?
        ((@offset % divisor) / 60).round
      end

      def to_s
        sprintf('%02d:%02d:%02d.%06d%+05d', hour, min, sec, fraction * 1000000,
                offset_hours * 100 + offset_minutes)
      end

      def eql?(other)
        self.class == other.class &&
          self.hour     == other.hour &&
          self.min      == other.min &&
          self.sec      == other.sec &&
          self.fraction == other.fraction &&
          self.offset   == other.offset
      end
      alias :== :eql?

      class << self

        def parse(string = '00:00:00+00:00')
          segments     = ::Date._parse(string)
          hour         = segments[:hour] || 0
          min          = segments[:min] || 0
          sec          = segments[:sec] || 0
          sec_fraction = segments[:sec_fraction] || 0
          offset       = segments[:offset] || 0
          new(hour, min, sec, sec_fraction, offset)
        end

        private

        def cast_to_datetime(object, *args)
          datetime = object.to_datetime
          Time.new(
            datetime.hour, datetime.minute, datetime.second,
            datetime.sec_fraction, datetime.offset * 86400
          )
        end
        alias :load_Time :cast_to_datetime
        alias :load_Date :cast_to_datetime

        def load_String(object, *args)
          Time.parse(object)
        end

      end

    end
  end
end
