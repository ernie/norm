module Norm
  module SQL
    class Statement < Fragment

      def fragmentize_args(fragment_class, args)
        possible_fragment = args.first
      end

      private

      def compile!
        nec = non_empty_clauses
        sql = nec.map(&:sql).join("\n")
        params = nec.map(&:params).inject(&:+) || []
        @sql, @params = sql, params
      end

      def non_empty_clauses
        clauses.reject(&:empty?)
      end

    end
  end
end
