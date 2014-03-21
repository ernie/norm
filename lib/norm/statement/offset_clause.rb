module Norm
  module Statement
    class OffsetClause < ValueClause

      def sql
        "OFFSET #{@fragment.sql}"
      end

      def params
        @fragment.params
      end

    end
  end
end
