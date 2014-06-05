module Norm
  module SQL
    class SetFragment < Fragment

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
          attr = Attribute::Identifier(attr)
          case value
          when nil
            sql << "#{attr} = NULL"
          when Attribute::Default, Attribute::Identifier
            sql << "#{attr} = #{value}"
          else
            params << value
            sql << "#{attr} = $?"
          end
        }
        [sql.join(', '), params]
      end

    end
  end
end
