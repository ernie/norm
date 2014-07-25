module Norm
  module SQL
    class Select < Statement

      def initialize(*args)
        @withs   = WithClause.new
        @selects = SelectClause.new
        @froms   = FromClause.new
        @wheres  = WhereClause.new
        @groups  = GroupClause.new
        @havings = HavingClause.new
        @orders  = OrderClause.new
        @limit   = LimitClause.new
        @offset  = OffsetClause.new
        args.empty? ? select!('*') : select!(*args)
      end

      def initialize_copy(orig)
        @withs      = @withs.dup
        @selects    = @selects.dup
        @froms      = @froms.dup
        @wheres     = @wheres.dup
        @groups     = @groups.dup
        @havings    = @havings.dup
        @orders     = @orders.dup
        @limit      = @limit.dup
        @offset     = @offset.dup
        @sql        = nil
        @params     = nil
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

      def select(*args)
        dup.select!(*args)
      end

      def select!(*args)
        @selects << Fragment.new(*args)
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

      def group(*args)
        dup.group!(*args)
      end

      def group!(*args)
        @groups << Fragment.new(*args)
        self
      end

      def having(*args)
        dup.having!(*args)
      end

      def having!(*args)
        @havings << PredicateFragment.new(*args)
        self
      end

      def order(*args)
        dup.order!(*args)
      end

      def order!(*args)
        @orders << Fragment.new(*args)
        self
      end

      def limit(*args)
        dup.limit!(*args)
      end

      def limit!(*args)
        @limit.value = Fragment.new(*args)
        self
      end

      def offset(*args)
        dup.offset!(*args)
      end

      def offset!(*args)
        @offset.value = Fragment.new(*args)
        self
      end

      private

      def clauses
        [@withs, @selects, @froms, @wheres, @havings, @groups, @orders, @limit,
         @offset]
      end

    end
  end
end
