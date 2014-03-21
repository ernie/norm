module Norm
  module Statement
    class FromClause < CollectionClause

      def sql
        "FROM #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
