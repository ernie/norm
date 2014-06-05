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

      alias :inspect :to_s

      class << self

        private

        def datetime_to_timestamp(object, *args)
          datetime = object.to_datetime.new_offset(0)
          seconds_with_fraction = datetime.second + datetime.sec_fraction
          Timestamp.new(
            datetime.year, datetime.month, datetime.day,
            datetime.hour, datetime.minute, seconds_with_fraction,
            datetime.offset
          )
        end
        alias :load_Time                     :datetime_to_timestamp
        alias :load_Date                     :datetime_to_timestamp
        alias :load_DateTime                 :datetime_to_timestamp
        alias :load_Norm_Attribute_Timestamp :datetime_to_timestamp

        def load_String(object, *args)
          datetime_to_timestamp DateTime.parse(object)
        end

      end

    end

    def self.Timestamp(*)
      Timestamp
    end

  end
end
