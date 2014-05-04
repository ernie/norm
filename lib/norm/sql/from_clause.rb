module Norm
  module SQL
    class FromClause < CollectionClause

      def sql
        "FROM #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
