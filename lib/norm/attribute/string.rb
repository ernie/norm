module Norm
  module Attribute
    class String
      extend Loading

      class << self

        def load_Object(object, size = nil, *args)
          size ? object.to_s[0, size] : object.to_s
        end

      end

    end

    def self.String(*args)
      Loader.new(String, *args)
    end

  end
end
