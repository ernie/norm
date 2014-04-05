module Norm
  module Statement
    class Delete < SQL

      def initialize(*args)
        @delete    = DeleteClause.new
        @usings    = UsingClause.new
        @wheres    = WhereClause.new
        @returning = ReturningClause.new
        delete!(*args) unless args.empty?
      end

      def initialize_copy(orig)
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

      def compile!
        clauses = non_empty_clauses
        sql = clauses.map(&:sql).join("\n")
        params = clauses.map(&:params).inject(&:+) || []
        @sql, @params = sql, params
      end

      def non_empty_clauses
        [@delete, @usings, @wheres, @returning].reject(&:empty?)
      end

    end
  end
end
