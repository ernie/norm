module Norm
  module Statement
    class GroupClause < CollectionClause

      def sql
        "GROUP BY #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
