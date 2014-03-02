module Norm
  module Statement
    class Statement
      attr_reader :sql, :params, :result_format

      def initialize(sql = '', params = {})
        @sql           = sql
        @params        = normalize_params(params)
        @result_format = :text
      end

      private

      def normalize_params(params)
        params.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
      end

    end
  end
end
