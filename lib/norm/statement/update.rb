module Norm
  module Statement
    class Update < SQL

      def initialize(*args)
        @update    = UpdateClause.new
        @sets      = SetClause.new
        @froms     = FromClause.new
        @wheres    = WhereClause.new
        @returning = ReturningClause.new
        update!(*args) unless args.empty?
      end

      def initialize_copy(orig)
        @update    = @update.dup
        @sets      = @sets.dup
        @froms     = @froms.dup
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

      def update(*args)
        dup.update!(*args)
      end

      def update!(*args)
        @update.value = Fragment.new(*args)
        self
      end

      def set(*args)
        dup.set!(*args)
      end

      def set!(*args)
        @sets << SetFragment.new(*args)
        self
      end

      def from(*args)
        dup.from!(*args)
      end

      def from!(*args)
        @froms << Fragment.new(*args)
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
        [@update, @sets, @froms, @wheres, @returning].reject(&:empty?)
      end

    end
  end
end
