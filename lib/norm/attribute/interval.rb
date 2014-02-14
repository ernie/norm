module Norm
  module Attribute
    class Interval
      extend Loading
      include Comparable

      YEAR, MONTH, DAY, HOUR, MINUTE, SECOND = 0..5

      attr_reader :years, :months, :days, :seconds

      def initialize(years, months, days, seconds)
        @years, @months, @days, @seconds =
          years.to_r, months.to_r, days.to_r, seconds.to_r
        normalize!
      end

      def to_s
        (word_parts + number_parts).join(' ')
      end

      def to_r
        # Interestingly, extracting epoch from an interval of a year yields a
        # number that accounts for an extra 1/4 days, but extracting it from a
        # month or day doesn't treat them as 1/12th of that number, or
        # 1/365.25th, respectively. I'm just following PostgreSQL's example,
        # here.
        [@years * 31557600, @months * 2592000, @days * 86400, @seconds].
          inject(&:+)
      end

      def to_i
        to_r.to_i
      end

      def to_f
        to_r.to_f
      end

      def <=>(other)
        Interval === other ? self.to_r <=> other.to_r : self.to_r <=> other
      end

      def eql?(other)
        self.class == other.class &&
          self.to_r == other.to_r
      end

      private

      def normalize!
        @years, remainder = extract_fraction @years
        @months += remainder / Rational(1, 12)
        @months, remainder = extract_fraction @months
        @days += remainder / Rational(1, 30)
        @days, remainder = extract_fraction @days
        @seconds += ((remainder / Rational(1, 24)) * 3600).round(6)
        @years, @months = @years + @months / 12, @months % 12
      end

      def extract_fraction(number)
        mod = number < 0 ? -1 : 1
        [(number / 1).to_i, Rational(number, 1) % mod]
      end

      def inflect(number, word)
        if number.abs == 1
          "#{number} #{word}"
        else
          "#{number} #{word}s"
        end
      end

      def word_parts
        @word_parts ||= [years_string, months_string, days_string].compact
      end

      def number_parts_sign
        @seconds < 0 ? '-' : ''
      end

      def number_parts
        @number_parts ||= if @seconds.zero? && word_parts.any?
                            []
                          else
                            [
                              sprintf(
                                "#{number_parts_sign}%02d:%02d:%02d.%06d",
                                abs_hours, abs_minutes, abs_seconds,
                                abs_seconds_remainder * 1000000
                              )
                            ]
                          end
      end

      def abs_hours
        (@seconds.abs / 3600).to_i
      end

      def abs_hours_remainder
        @seconds.abs % 3600
      end

      def abs_minutes
        (abs_hours_remainder / 60).to_i
      end

      def abs_minutes_remainder
        abs_hours_remainder % 60
      end

      def abs_seconds
        abs_minutes_remainder.to_i
      end

      def abs_seconds_remainder
        abs_minutes_remainder % 1
      end

      def years_string
        inflect(@years, 'year') if @years.nonzero?
      end

      def months_string
        inflect(@months, 'month') if @months.nonzero?
      end

      def days_string
        inflect(@days, 'day') if @days.nonzero?
      end


      class << self

        private

        def load_String(object, *args)
          parsed = Parsing::Interval.new(object)
          new(parsed.years, parsed.months, parsed.days, parsed.seconds)
        end

      end

    end
  end
end
