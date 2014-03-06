module Norm
  module Statement
    class SQL

      HASH_INTERPOLATION_REGEXP = /\\?\$:([\w\.]+)/

      attr_reader :sql, :params

      def initialize(sql = '', first = :__nil__, *args)
        if args.empty? && Hash === first
          @sql, @params = interpolate_hash_params(sql, first)
        elsif first == :__nil__
          @sql, @params = sql, []
        else
          args.unshift(first)
          @sql, @params = sql, args
        end
      end

      def interpolate_hash_params(sql, hash_params)
        hash_params = stringify_hash(hash_params)
        params = []
        sql = sql.gsub(HASH_INTERPOLATION_REGEXP) { |match|
          if match.start_with? '\\'
            "$:#{$1}"
          else
            params << fetch_hash_interpolation($1, hash_params)
            '$?'
          end
        }
        [sql, params]
      end

      def fetch_hash_interpolation(string, hash_params)
        key, rest = string.split('.', 2)
        value = hash_params[key]
        Hash === value ? fetch_hash_interpolation(rest, value) : value
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
