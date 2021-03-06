module Norm
  module SQL
    class Fragment

      HASH_INTERPOLATION = /\\?\$([a-zA-Z][\w\.]*)/

      attr_reader :sql, :params

      def initialize(sql = '', *args)
        if Hash === args.first
          @params = []
          @sql = interpolate_hash_params(sql.to_s, args.first)
        else
          @sql, @params = sqlify(sql).to_s, args
        end
      end

      private

      def sqlify(object)
        Symbol === object ? Attribute::Identifier(object) : object
      end

      def interpolate_hash_params(sql, hash_params)
        hash_params = stringify_hash(hash_params)
        sql.gsub(HASH_INTERPOLATION) { |match|
          if match.start_with? '\\'
            "$#{$1}"
          else
            @params << fetch_hash_interpolation($1, hash_params)
            '$?'
          end
        }
      end

      def fetch_hash_interpolation(string, hash_params, original = string)
        key, rest = string.split('.', 2)
        value = hash_params.fetch(key) { missing_interpolation!(original) }
        Hash === value ? fetch_hash_interpolation(rest, value, original) : value
      end

      def missing_interpolation!(original)
        raise MissingInterpolationError,
          "Missing content for \"#{original}\"."
      end

      def stringify_hash(hash)
        hash = hash.dup
        hash.keys.each do |key|
          value = hash.delete key
          hash[key.to_s] = Hash === value ? stringify_hash(value) : value
        end
        hash
      end

    end
  end
end
