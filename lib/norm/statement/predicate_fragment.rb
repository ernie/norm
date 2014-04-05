module Norm
  module Statement
    class PredicateFragment < Fragment

      def initialize(*args)
        if Hash === args.first
          @sql, @params = build_from_hash(args.first)
        else
          super
        end
      end

      def build_from_hash(hash)
        sql    = []
        params = []
        hash.map { |attr, value|
          if value.nil?
            sql << "#{quote_identifier(attr)} IS NULL"
          else
            params << value
            sql << "#{quote_identifier(attr)} = $?"
          end
        }
        [sql.join(' AND '), params]
      end

    end
  end
end
