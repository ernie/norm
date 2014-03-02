module Norm
  module Statement
    class Insert < Statement

      def param_keys
        params.keys.join(', ')
      end

      def param_values
        params.keys.map { |k| "%{#{k}}" }.join(', ')
      end

    end
  end
end
