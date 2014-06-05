require 'date'

module Norm
  module Attribute
    class Date
      extend Loading

      class << self

        private

        def cast_to_date(object, *args)
          object.to_date
        end
        alias :load_Time :cast_to_date
        alias :load_DateTime :cast_to_date

        def load_Date(object, *args)
          object.dup
        end

        def load_String(object, *args)
          ::Date.parse(object)
        end

      end

    end

    def self.Date(*)
      Date
    end

  end
end
