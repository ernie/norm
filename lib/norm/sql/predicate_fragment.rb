module Norm
  module SQL
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
        hash.each do |attr, value|
          attr = Attribute::Identifier(attr)
          case value
          when nil
            sql << "#{attr} IS NULL"
          when Array
            if value.include?(nil)
              sql << 'FALSE /* IN with NULL value is never TRUE */'
            else
              sql << "#{attr} IN (#{
                (['$?'] * value.size).join(', ')
              })"
              params.concat(value)
            end
          else
            params << value
            sql << "#{attr} = $?"
          end
        end
        [sql.join(' AND '), params]
      end

    end
  end
end
