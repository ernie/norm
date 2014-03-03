module Norm
  module Statement
    class Insert < Statement

      def non_private_param_keys
        params.keys.reject { |k| k.start_with? '_' }
      end

      def param_keys
        non_private_param_keys.join(', ')
      end

      def param_values
        non_private_param_keys.map { |k| "%{#{k}}" }.join(', ')
      end

    end
  end
end
