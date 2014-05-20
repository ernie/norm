module Norm
  class Attributes
    EMPTY = [].freeze
    NonexistentAttributeError = Class.new(Error)

    def self.names
      EMPTY
    end

    def self.identity(*names)
      if names.empty?
        raise ArgumentError, 'Identity requires at least one attribute'
      end
      names = names.map(&:to_s)
      define_method(:identifiers) { |default: false|
        get_attributes(*names, default: default)
      }
    end

    def self.attribute(name, loader)
      name = name.to_s
      my_names = names | [name]
      define_singleton_method(:names) { super() | my_names }
      define_method("_set_#{name}") { |obj|
        @attributes[name] = loader.load(obj)
      }
      define_method("_get_#{name}") { |default: false|
        @attributes.fetch(name, default ? Attribute::Default.instance : nil)
      }
      private "_set_#{name}", "_get_#{name}"
    end

    def initialize(attributes = {})
      @attributes = {}
      attributes.each do |name, value|
        send("_set_#{name}", value) if has_key?(name)
      end
      yield self if block_given?
      initialized!
    end

    def names
      self.class.names
    end

    def set(name, value)
      return send("_set_#{name}", value) unless initialized?

      name       = name.to_s
      changes    = @updates[name]
      new_value  = send("_set_#{name}", value)
      changes[1] = new_value
      @updates.delete(name) if changes.first == new_value
      new_value
    rescue NoMethodError => e
      @updates.delete(name) if initialized?
      raise NonexistentAttributeError, "No such attribute: #{name}", e.backtrace
    end
    alias :[]= :set

    def get(name, default: false)
      send("_get_#{name}", default: default)
    rescue NoMethodError => e
      raise NonexistentAttributeError, "No such attribute: #{name}", e.backtrace
    end
    alias :[] :get

    def all(default: false)
      get_attributes(*names, default: default)
    end

    def initialized!
      clear_updates!
      @initialized = true
    end

    def initialized?
      !!@initialized
    end

    def initialized
      get_attributes(*(names & @attributes.keys))
    end

    def updated
      get_attributes(*(names & @updates.keys))
    end

    def updated?
      @updates.any?
    end

    def identifiers(default: false)
      {}
    end

    def updates
      @updates.dup.tap { |updates| updates.default_proc = nil }
    end

    def get_attributes(*names, default: false)
      names.each_with_object({}) { |name, hash|
        hash[name] = get(name, default: default)
      }
    end

    def values_at(*names, default: false)
      get_attributes(*names, default: false).values
    end

    def has_key?(name)
      respond_to?("_set_#{name}", true)
    end

    def set_attributes(attributes)
      attributes.each do |name, value|
        set(name, value) if has_key?(name)
      end
    end

    def clear_updates!
      @updates = Hash.new { |h, k| h[k] = [get(k, default: true), nil] }
    end

    def inspect
      "#<#{self.class} #{
        all(default: true).map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
      }>"
    end

    def ==(other)
      !!(self.class <=> other.class) &&
        self.identity? && other.identity? &&
        self.identifiers == other.identifiers
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        self.identity? && other.identity? &&
        self.identifiers.eql?(other.identifiers)
    end

    def hash
      if identity?
        self.class.hash ^ identifiers.hash
      else
        super
      end
    end

    def identity?
      ids = identifiers
      ids.any? && ids.none? { |k, v| v.nil? }
    end

  end
end
