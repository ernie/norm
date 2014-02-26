module Norm
  module Parser
    class Statement

      REGEXP = /\\?%{(\w+)}/
      FORMATS = { :text => 0, :binary => 1 }

      attr_reader :sql, :params, :format

      def initialize(statement)
        @statement = statement
        @format    = FORMATS.fetch(statement.format, 0)
        @params    = []
        parse!
      end

      private

      def parse!
        counter = Range.new(1, Float::INFINITY).to_enum
        sql, params = @statement.sql, @statement.params
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
