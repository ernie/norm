module Norm
  module Constraint
    class AddErrorsDelegate < Delegate
      CONSTRAINT = /\A(?<column>[^:]+):(?<key>[^\(\s#]+)(\((?<opts>[^)]*)\))?/

      def initialize(errors)
        @errors = errors
      end

      def constraint_error(error)
        add_error_from_constraint_name(error.constraint_name) ||
          send("#{error.type}_error", error)
      end

      private

      def check_error(error)
        @errors.add(:base, :invalid)
      end

      def exclusion_error(error)
        @errors.add(:base, :invalid)
      end

      def foreign_key_error(error)
        @errors.add(:base, :invalid)
      end

      def not_null_error(error)
        @errors.add(error.column_name || :base, :blank)
      end

      def restrict_error(error)
        @errors.add(:base, :invalid)
      end

      def unique_error(error)
        @errors.add(:base, :invalid)
      end

      def add_error_from_constraint_name(name)
        if match = CONSTRAINT.match(name.to_s)
          column, key, opts = match[:column], match[:key], match[:opts]
          opts = Hash[
            opts.to_s.split(/,\s*/).map { |kv|
              k, v = kv.split(/:\s*/, 2)
              [k.to_sym, v]
            }
          ]
          @errors.add(column.to_sym, key.to_sym, opts)
          true
        end
      end

    end
  end
end
