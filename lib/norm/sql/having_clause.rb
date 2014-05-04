module Norm
  module SQL
    class HavingClause < CollectionClause

      def sql
        "HAVING #{@fragments.map(&:sql).join(' AND ')}"
      end

    end
  end
end
