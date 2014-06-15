module Norm
  module Constraint
    class AddErrorsDelegate < Delegate
      CONSTRAINT = /\A(?<column>[^:]+):(?<key>[^\(]+)(\((?<opts>[^)]*)\))?\z/

      def initialize(errors)
        @errors = errors
      end

      def constraint_error(error)
        send("#{error.type}_error", error)
      end

      private

      def check_error(error)
        if error.constraint_name
          @errors.add(*options_from_constraint_name(error.constraint_name))
        else
          @errors.add(error.column_name || :base, :invalid)
        end
      end

      def exclusion_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def foreign_key_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def not_null_error(error)
        @errors.add(error.column_name || :base, :blank)
      end

      def restrict_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def unique_error(error)
        @errors.add(error.column_name || :base, :invalid)
      end

      def options_from_constraint_name(name)
        if match = CONSTRAINT.match(name)
          column, key, opts = match[:column], match[:key], match[:opts]
          opts = Hash[
            opts.to_s.split(/,\s*/).map { |kv|
              k, v = kv.split(/:\s*/, 2)
              [k.to_sym, v]
            }
          ]
          [column.to_sym, key.to_sym, opts]
        else
          [:base, :invalid]
        end
      end

    end
  end
end
