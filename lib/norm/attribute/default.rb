require 'singleton'

module Norm
  module Attribute
    class Default
      include Singleton

      def to_s
        'DEFAULT'
      end

      def inspect
        '<DEFAULT>'
      end
    end

    DEFAULT = Default.instance

  end
end
