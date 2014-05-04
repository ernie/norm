module Norm
  module SQL
    class SelectClause < CollectionClause

      def sql
        "SELECT #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
