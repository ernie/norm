require 'bigdecimal'
module Norm
  module Attribute
    class Decimal
      extend Loading

      class << self

        private

        def new_big_decimal(object, precision = 0, scale = nil, *args)
          if scale
            BigDecimal.new(object, precision).round(scale)
          else
            BigDecimal.new(object, precision)
          end
        end
        alias :load_Numeric :new_big_decimal
        alias :load_String  :new_big_decimal

      end

    end

    def self.Decimal(*args)
      Loader.new(Decimal, *args)
    end

  end
end
