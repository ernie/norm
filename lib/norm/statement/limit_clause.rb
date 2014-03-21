module Norm
  module Statement
    class LimitClause < ValueClause

      def sql
        "LIMIT #{@fragment.sql}"
      end

      def params
        @fragment.params
      end

    end
  end
end
