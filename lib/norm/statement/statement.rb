module Norm
  module Statement
    class Statement
      attr_reader :sql, :params, :result_format

      def initialize(sql = '', params = [], result_format = 0)
        @sql, @params, @result_format = sql, params, result_format
      end

    end
  end
end
