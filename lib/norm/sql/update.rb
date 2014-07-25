module Norm
  module SQL
    class Update < Statement

      def initialize(*args)
        @withs     = WithClause.new
        @update    = UpdateClause.new
        @sets      = SetClause.new
        @froms     = FromClause.new
        @wheres    = WhereClause.new
        @returning = ReturningClause.new
        update!(*args) unless args.empty?
      end

      def initialize_copy(orig)
        @withs     = @withs.dup
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

      def with(*args)
        dup.with!(*args)
      end

      def with!(*args, recursive: false, **opts)
        @withs << CTE.new(*args, **opts)
        @withs.recursive! if recursive
        self
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

      def clauses
        [@withs, @update, @sets, @froms, @wheres, @returning]
      end

    end
  end
end
