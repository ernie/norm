module Norm
  module Statement
    class Select < SQL

      def initialize(*args)
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
        @selects    = @selects.dup
        @froms      = @froms.dup
        @wheres     = @wheres.dup
        @groups     = @groups.dup
        @havings    = @havings.dup
        @orders     = @orders.dup
        @offset     = @offset.dup
        @limit      = @limit.dup
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

      def compile!
        clauses = non_empty_clauses
        sql = clauses.map(&:sql).join("\n")
        # TODO: limit, offset
        params = clauses.map(&:params).inject(&:+)
        @sql, @params = sql, params
      end

      def non_empty_clauses
        [@selects, @froms, @wheres, @havings,
         @groups, @orders, @offset, @limit].reject(&:empty?)
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
        @having << PredicateFragment.new(*args)
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

    end
  end
end
