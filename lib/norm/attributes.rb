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
      names = names.map(&:to_sym)
      define_method(:identifiers) { |default: false|
        get_attributes(*names, default: default)
      }
      define_method(:<=>) { |other|
        unless self.class.eql?(other.class) && identity? && other.identity?
          return nil
        end
        values_at(*names) <=> other.values_at(*names)
      }
    end

    def self.attribute(name, loader)
      name = name.to_sym
      my_names = names | [name]
      define_singleton_method(:names) { super() | my_names }
      define_method("_set_#{name}") { |obj|
        @attributes[name] = loader.load(obj)
      }
      define_method("_orig_#{name}") { |default: false|
        @originals.fetch(name, default ? Attribute::Default.instance : nil)
      }
      define_method("_get_#{name}") { |default: false|
        @attributes.fetch(name, default ? Attribute::Default.instance : nil)
      }
      private "_set_#{name}", "_get_#{name}"
    end

    def initialize(attributes = {})
      @attributes = {}
      set_attributes(attributes)
      yield self if block_given?
      initialized!
    end

    def names
      self.class.names
    end

    def []=(name, value)
      require_key!(name)
      send("_set_#{name}", value)
    end

    def [](name, default: false)
      require_key!(name)
      send("_get_#{name}", default: default)
    end

    def orig(name, default: false)
      require_key!(name)
      send("_orig_#{name}", default: default)
    end

    def all(default: false)
      get_attributes(*names, default: default)
    end

    def initialized?
      !!@initialized
    end

    def initialized
      get_attributes(*(names & @attributes.keys))
    end

    def updated?
      updates.any?
    end

    def updated
      get_attributes(*updated_names)
    end

    def updated_names
      names.select { |name|
        orig(name, default: true) != self[name, default: true]
      }
    end

    def updates
      updated_names.each_with_object({}) { |name, hash|
        hash[name] = self[name]
      }
    end

    def identity?
      ids = identifiers
      ids.any? && ids.none? { |k, v| v.nil? }
    end

    def identifiers(default: false)
      {}
    end

    def get_attributes(*names, default: false)
      names.each_with_object({}) { |name, hash|
        hash[name] = self[name, default: default]
      }
    end

    def set_attributes(attributes)
      attributes.each do |name, value|
        self[name] = value if has_key?(name)
      end
    end

    def get_originals(*names, default: false)
      names.each_with_object({}) { |name, hash|
        hash[name] = orig(name, default: default)
      }
    end

    def values_at(*names, default: false)
      get_attributes(*names, default: default).values
    end

    def has_key?(name)
      respond_to?("_set_#{name}", true)
    end

    def commit!
      @originals = @attributes.dup
    end

    def reset!
      @attributes = @originals.dup
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

    def <=>(other)
      nil
    end

    private

    def initialized!
      commit!
      @initialized = true
    end

    def require_key!(name)
      unless has_key?(name)
        raise NonexistentAttributeError, "No such attribute: #{name}"
      end
    end

  end
end
