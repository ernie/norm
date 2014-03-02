module Norm
  module Parser
    class Statement
      ParseError = Class.new(StandardError)

      METHODS_REGEXP = /\\?&{(\w+)}/
      PARAMS_REGEXP  = /\\?%{(\w+)}/
      RESULT_FORMATS = { :text => 0, :binary => 1 }

      attr_reader :sql, :params, :result_format

      def initialize(statement)
        @statement     = statement
        @result_format = RESULT_FORMATS.fetch(statement.result_format, 0)
        @params        = []
        parse!
      end

      private

      def parse!
        sql, params = @statement.sql, @statement.params
        @sql = interpolate_params(interpolate_methods(sql), params)
      end

      def interpolate_methods(sql)
        sql.gsub(METHODS_REGEXP) { |match|
          if match.start_with? '\\'
            "&{#{$1}}"
          else
            @statement.public_send($1)
          end
        }
      rescue NoMethodError => e
        raise ParseError,
          "Statement (#{@statement}) has no public method named \"#{$1}\"",
          e.backtrace
      end

      def interpolate_params(sql, params)
        counter = Range.new(1, Float::INFINITY).to_enum
        sql.gsub(PARAMS_REGEXP) { |match|
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
