module Norm
  module Parser
    module Attribute
      class Interval

        REGEXP = /
          ((\s+|\A)(?<years>[\-\d\.]+)\s+years?)?
          ((\s+|\A)(?<months>[\-\d\.]+)\s+mon(th)?s?)?
          ((\s+|\A)(?<days>[\-\d\.]+)\s+days?)?
          ((\s+|\A)(?<hours>[\-\d\.]+)\s+h(ou)?rs?)?
          ((\s+|\A)(?<minutes>[\-\d\.]+)\s+min(ute)?s?)?
          ((\s+|\A)(?<seconds>[\-\d\.]+)\s+sec(ond)?s?)?
          ((\s+|\A)(?<negative_seg>\-))?
          ((\s+|\A)?(?<hours_seg>\d+)(?=:\d+(:[\d\.]+)?(\s+|\z)))?
          (\s+|\A|:)?
          ((?<=\d:)(?<minutes_seg>\d+)(?=(:[\d\.]+)?(\s+|\z)))?
          ((?<=(\s|\A))(?<minutes_seg>\d+)(?=(:[\d\.]+)(\s+|\z)))?
          ((\s+|\A|:)?(?<seconds_seg>[\d\.]+)(?=(\s+|\z)))?
        /xi

        attr_reader :years, :months, :days, :seconds

        def initialize(string)
          @match = REGEXP.match(string)
          validate!
          @years, @months, @days =
            @match[:years].to_r, @match[:months].to_r, @match[:days].to_r
          @seconds = explicit_seconds + segment_seconds
        end

        private

        def validate!
          if match_empty? || hour_and_minute_conflicts? || second_conflicts?
            raise ArgumentError, 'Invalid input syntax'
          end
        end

        def match_empty?
          !@match || @match.captures.compact.none? { |c| c != '-' }
        end

        def hour_and_minute_conflicts?
          (@match[:hours] || @match[:minutes]) &&
            (@match[:hours_seg] || @match[:minutes_seg])
        end

        def second_conflicts?
          @match[:seconds] &&
            (@match[:hours_seg] || @match[:minutes_seg] || @match[:seconds_seg])
        end

        def explicit_seconds
          to_seconds(@match[:hours], @match[:minutes], @match[:seconds])
        end

        def segment_seconds
          sum = to_seconds(
            @match[:hours_seg], @match[:minutes_seg], @match[:seconds_seg]
          )
          @match[:negative_seg] ? -sum : sum
        end

        def to_seconds(hours, minutes, seconds)
          hours.to_r * 3600 +
            minutes.to_r * 60 +
            seconds.to_r
        end

      end
    end
  end
end
