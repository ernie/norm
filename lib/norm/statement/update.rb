module Norm
  module Statement
    class Update < SQL

      def initialize(table_name)
        @update = UpdateClause.new(table_name)
      end

    end
  end
end
