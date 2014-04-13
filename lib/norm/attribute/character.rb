module Norm
  module Attribute
    class Character
      extend Loading

      class << self

        private

        def load_Object(object, size = 1, *args)
          object.to_s[0, size].ljust(size)
        end

      end

    end

    def self.Character(*args)
      Delegator.new(Character, *args)
    end

  end
end
