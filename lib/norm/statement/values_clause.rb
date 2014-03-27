module Norm
  module Statement
    class ValuesClause < CollectionClause

      def <<(fragment)
        super(Grouping.new(fragment))
      end

      def sql
        "VALUES #{@fragments.map(&:sql).join(', ')}"
      end

    end
  end
end
