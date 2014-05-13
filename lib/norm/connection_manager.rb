require 'connection_pool'

module Norm
  class ConnectionManager
    attr_reader :pools

    def initialize(spec = {})
      spec = spec.each_with_object({:primary => {}}) { |(k, v), h|
        h[k.to_sym] = v
      }
      @pools = {}
      spec.each do |name, config|
        config = config.dup
        pool_config = {
          :size => config.delete('pool') || 5,
          :timeout => config.delete('pool_timeout') || 5
        }
        pools[name] = ConnectionPool.new(pool_config) {
          Connection.new(name, config)
        }
      end
    end

    def with_connections(first, *rest, &block)
      rest.unshift first
      conns, names = rest.partition { |c| Connection === c }
      if names.any?
        pools[names.shift.to_sym].with do |conn|
          with_connections(*((conns << conn) + names), &block)
        end
      else
        yield *conns
      end
    end

    def with_connection(name, &block)
      with_connections(name, &block)
    end

    def atomically_on(first, *rest, result: false, &block)
      res = do_atomically_on(first, *rest, &block)
      result ? Result.new(true, res) : res
    rescue ConstraintError => e
      result ? Result.new(false, e) : raise(e)
    end

    private

    def do_atomically_on(first, *rest, &block)
      rest.unshift first
      conns, names = rest.partition { |c| Connection === c }
      if names.any?
        pools[names.shift.to_sym].with do |conn|
          conn.atomically do |conn|
            atomically_on(*((conns << conn) + names), &block)
          end
        end
      else
        yield *conns
      end
    end

  end
end
