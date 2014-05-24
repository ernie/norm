module Norm
  module SQL
    class Statement < Fragment

      def fragmentize_args(fragment_class, args)
        possible_fragment = args.first
      end

      private

      def compile!
        clauses = non_empty_clauses
        sql = clauses.map(&:sql).join("\n")
        params = clauses.map(&:params).inject(&:+) || []
        @sql, @params = sql, params
      end

    end
  end
end
