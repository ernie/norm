module Norm
  module SQL
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
