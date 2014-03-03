module Norm
  module Statement
    class Update < Statement

      def non_private_param_keys
        params.keys.reject { |k| k.start_with? '_' }
      end

      def param_sets
        non_private_param_keys.map { |k| "#{k} = %{#{k}}" }.join(', ')
      end

    end
  end
end
