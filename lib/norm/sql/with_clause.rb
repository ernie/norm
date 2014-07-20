module Norm
  module SQL
    class WithClause < CollectionClause

      def initialize(recursive: false)
        super()
        @recursive = !!recursive
      end

      def recursive!
        @recursive = true
      end

      def recursive?
        @recursive
      end

      def sql
        if recursive?
          "WITH RECURSIVE #{@fragments.map(&:sql).join(', ')}"
        else
          "WITH #{@fragments.map(&:sql).join(', ')}"
        end
      end

    end
  end
end
