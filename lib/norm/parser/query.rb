module Norm
  module Parser
    class Query

      REGEXP = /\\?%{(\w+)}/

      attr_reader :sql, :params

      def initialize(query)
        @query  = query
        @params = []
        parse!
      end

      private

      def parse!
        counter = Range.new(1, Float::INFINITY).to_enum
        sql, params = @query.sql, @query.params
        @sql = sql.gsub(REGEXP) { |match|
          if match.start_with? '\\'
            "%{#{$1}}"
          else
            @params << params[$1]
            "$#{counter.next}"
          end
        }
      end

    end
  end
end
