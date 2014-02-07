module Norm
  module Attribute
    class Integer
      extend Loading

      class << self

        private

        alias :load_Integer    :noop

        def call_to_i(object, *args)
          object.to_i
        end
        alias :load_String     :call_to_i
        alias :load_Numeric    :call_to_i

      end

    end
  end
end
