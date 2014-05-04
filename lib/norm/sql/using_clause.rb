module Norm
  module SQL
    class UsingClause < CollectionClause

      def sql
        "USING #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
