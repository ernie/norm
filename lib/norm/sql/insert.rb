module Norm
  module SQL
    class Insert < Statement

      def initialize(*args)
        @insert    = InsertClause.new
        @values    = ValuesClause.new
        @returning = ReturningClause.new
        insert!(*args) unless args.empty?
      end

      def initialize_copy(orig)
        @insert    = @insert.dup
        @values    = @values.dup
        @returning = @returning.dup
        @sql       = nil
        @params    = nil
      end

      def sql
        return @sql if @sql
        compile!
        @sql
      end

      def params
        return @params if @params
        compile!
        @params
      end

      def insert!(*args)
        @insert.value = Fragment.new(*args)
        self
      end

      def insert(*args)
        dup.insert!(*args)
      end

      def values(*args)
        dup.values!(*args)
      end

      def values!(*args)
        @values << Fragment.new((['$?'] * args.size).join(', '), *args)
        self
      end

      def values_sql(*args)
        dup.values_sql!(*args)
      end

      def values_sql!(*args)
        @values << Fragment.new(*args)
        self
      end

      def returning(*args)
        dup.returning!(*args)
      end

      def returning!(*args)
        @returning.value = Fragment.new(*args)
        self
      end

      private

      def non_empty_clauses
        [@insert, @values, @returning].reject(&:empty?)
      end

    end
  end
end
