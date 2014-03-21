module Norm
  module Statement
    class SelectClause < CollectionClause

      def sql
        "SELECT #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
