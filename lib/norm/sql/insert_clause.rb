module Norm
  module SQL
    class InsertClause < ValueClause

      def sql
        "INSERT INTO #{@fragment.sql}"
      end

    end
  end
end
