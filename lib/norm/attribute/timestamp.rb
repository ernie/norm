require 'date'

module Norm
  module Attribute
    class Timestamp < DateTime
      extend Loading

      def to_s
        strftime('%Y-%m-%d %H:%M:%S%z')
      end

      class << self

        private

        def cast_to_datetime(object, *args)
          datetime = object.to_datetime.new_offset(0)
          Timestamp.new(
            datetime.year, datetime.month, datetime.day,
            datetime.hour, datetime.minute, datetime.second, datetime.offset
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
