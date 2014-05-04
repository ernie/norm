module Norm
  module SQL
    class GroupClause < CollectionClause

      def sql
        "GROUP BY #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
