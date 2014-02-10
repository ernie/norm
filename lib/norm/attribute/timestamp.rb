require 'date'

module Norm
  module Attribute
    class Timestamp < DateTime
      extend Loading

      def sec_fraction
        super.round(6)
      end

      def to_s
        strftime('%Y-%m-%d %H:%M:%S.%6N%z')
      end

      class << self

        private

        def cast_to_datetime(object, *args)
          datetime = object.to_datetime.new_offset(0)
          seconds_with_fraction = datetime.second + datetime.sec_fraction
          Timestamp.new(
            datetime.year, datetime.month, datetime.day,
            datetime.hour, datetime.minute, seconds_with_fraction,
            datetime.offset
          )
        end
        alias :load_Time :cast_to_datetime
        alias :load_Date :cast_to_datetime

        def load_DateTime(object, *args)
          object.new_offset(0)
        end
        alias :load_Norm_Attribute_Timestamp :load_DateTime

        def load_String(object, *args)
          Timestamp.parse(object).new_offset(0)
        end

      end

    end
  end
end
