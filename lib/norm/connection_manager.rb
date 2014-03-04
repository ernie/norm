require 'connection_pool'

module Norm
  class ConnectionManager
    attr_reader :pools

    def initialize(spec = {})
      @pools = {}
      spec = {'master' => {}}.merge(spec)
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

    def with_connections(*conns_or_names, &block)
      names, conns = conns_or_names.partition { |c| String === c }
      if names.any?
        pools[names.shift].with do |conn|
          with_connections(*((conns << conn) + names), &block)
        end
      else
        yield *conns
      end
    end

    def with_connection(name = 'master', &block)
      with_connections(name, &block)
    end

  end
end
