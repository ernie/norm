module Norm
  module Statement
    class SetClause < CollectionClause

      def sql
        "SET #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
