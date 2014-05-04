module Norm
  module SQL
    class DeleteClause < ValueClause

      def sql
        "DELETE FROM #{@fragment.sql}"
      end

    end
  end
end
