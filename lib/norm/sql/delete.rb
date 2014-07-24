module Norm
  module SQL
    class Delete < Statement

      def initialize(*args)
        @withs     = WithClause.new
        @delete    = DeleteClause.new
        @usings    = UsingClause.new
        @wheres    = WhereClause.new
        @returning = ReturningClause.new
        delete!(*args) unless args.empty?
      end

      def initialize_copy(orig)
        @withs    = @withs.dup
        @delete    = @delete.dup
        @usings    = @usings.dup
        @wheres    = @wheres.dup
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

      def with(*args)
        dup.with!(*args)
      end

      def with!(*args, recursive: false, **opts)
        @withs << CTE.new(*args, **opts)
        @withs.recursive! if recursive
        self
      end

      def delete(*args)
        dup.delete!(*args)
      end

      def delete!(*args)
        @delete.value = Fragment.new(*args)
        self
      end

      def using(*args)
        dup.using!(*args)
      end

      def using!(*args)
        @usings << Fragment.new(*args)
        self
      end

      def where(*args)
        dup.where!(*args)
      end

      def where!(*args)
        @wheres << PredicateFragment.new(*args)
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
        [@withs, @delete, @usings, @wheres, @returning].reject(&:empty?)
      end

    end
  end
end
