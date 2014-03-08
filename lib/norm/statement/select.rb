module Norm
  module Statement
    class Select < SQL

      class Clause
        def initialize(leader = nil, trailer = nil, separator = ', ')
          @separator, @leader, @trailer = separator, leader, trailer
          @fragments = []
        end

        def initialize_copy(orig)
          @fragments = @fragments.dup
        end

        def <<(fragment)
          @fragments << fragment
        end

        def empty?
          @fragments.empty?
        end

        def sql
          "#{@leader}#{@fragments.map(&:sql).join(@separator)}#{@trailer}"
        end

        def params
          @fragments.map(&:params).inject(&:+)
        end
      end

      def initialize(*args)
        @selects = Clause.new('SELECT ')
        @froms   = Clause.new('FROM ')
        @wheres  = Clause.new('WHERE ', nil, ' AND ')
        @havings = Clause.new('WHERE ', nil, ' AND ')
        @groups  = Clause.new('GROUP BY ')
        @orders  = Clause.new('ORDER BY ')
        @limit   = nil
        @offset  = nil
        args.empty? ? select!('*') : select!(*args)
      end

      def initialize_copy(orig)
        @selects = @selects.dup
        @froms   = @froms.dup
        @wheres  = @wheres.dup
        @havings = @havings.dup
        @groups  = @groups.dup
        @orders  = @orders.dup
        @sql     = nil
        @params  = nil
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
        sql = clauses.map(&:sql)
        # TODO: limit, offset
        params = clauses.map(&:params).inject(&:+)
        @sql, @params = sql, params
      end

      def non_empty_clauses
        [@selects, @froms, @wheres, @havings, @groups, @orders].reject(&:empty?)
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

      def having(*args)
        dup.having!(*args)
      end

      def having!(*args)
        @having << PredicateFragment.new(*args)
        self
      end

      def group(*args)
        dup.group!(*args)
      end

      def group!(*args)
        @groups << Fragment.new(*args)
        self
      end

      def order(*args)
        dup.order!(*args)
      end

      def order!(*args)
        @orders << Fragment.new(*args)
        self
      end

      def limit(limit)
        dup.limit!(limit)
      end

      def limit!(limit)
        @limit = limit
        self
      end

      def offset(offset)
        dup.offset!(offset)
      end

      def offset!(offset)
        @offset = offset
        self
      end

      def build_wheres
        @where.map { |attr, value|
          if value.nil?
            "#{quote_identifier(attr)} is null"
          else
            params << value
            "#{quote_identifier(attr)} = $#{counter.next}"
          end
        }.join(' AND ')
      end

    end
  end
end
