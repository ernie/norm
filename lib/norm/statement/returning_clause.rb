module Norm
  module Statement
    class ReturningClause < ValueClause

      def sql
        "RETURNING #{@fragment.sql}"
      end

      def params
        @fragment.params
      end

    end
  end
end
