module Norm
  module Statement
    class Update < Statement

      def param_sets
        params.keys.map { |k| "#{k} = %{#{k}}" }.join(', ')
      end

    end
  end
end
