module Norm
  module Statement
    class DeleteClause < ValueClause

      def sql
        "DELETE FROM #{@fragment.sql}"
      end

    end
  end
end
