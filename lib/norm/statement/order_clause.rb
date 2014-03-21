module Norm
  module Statement
    class OrderClause < CollectionClause

      def sql
        "ORDER BY #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
