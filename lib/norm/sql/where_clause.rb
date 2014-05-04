module Norm
  module SQL
    class WhereClause < CollectionClause

      def sql
        "WHERE #{@fragments.map(&:sql).join(' AND ')}"
      end

    end
  end
end
