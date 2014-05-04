module Norm
  module SQL
    class UpdateClause < ValueClause

      def sql
        "UPDATE #{@fragment.sql}"
      end

    end
  end
end
