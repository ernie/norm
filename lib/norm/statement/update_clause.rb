module Norm
  module Statement
    class UpdateClause < ValueClause

      def sql
        "UPDATE #{@fragment.sql}"
      end

    end
  end
end
