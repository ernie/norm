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
      define_singleton_method(:identifier_names) { names }
    end

    def self.identifier_names
      []
    end

    def self.attribute(name, loader)
      name = name.to_sym
      my_names = names | [name]
      define_singleton_method(:names) { super() | my_names }
      define_method("_set_#{name}") { |obj|
        @attributes[name] = loader.load(obj)
      }
      define_method("_orig_#{name}") { |default: false|
        val = @originals.fetch(name, default ? Attribute::DEFAULT : nil)
        default ? val : (val unless Attribute::DEFAULT == val)
      }
      define_method("_get_#{name}") { |default: false|
        val = @attributes.fetch(name, Attribute::DEFAULT)
        default ? val : (val unless Attribute::DEFAULT == val)
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

    def identifier_names
      self.class.identifier_names
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

    def initialized(default: false)
      get_attributes(*(names & @attributes.keys), default: default)
    end

    def updated?
      updated_names.any?
    end

    def updated(default: false)
      get_attributes(*updated_names, default: default)
    end

    def updated_names
      names.select { |name|
        orig(name, default: true) != self[name, default: true]
      }
    end

    def identity?
      ids = identifiers
      ids.any? && ids.none? { |k, v| v.nil? }
    end

    def identifiers(default: false)
      get_attributes(*identifier_names, default: default)
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
      names.map { |name| self[name, default: default] }
    end

    def original_values_at(*names, default: false)
      names.map { |name| orig(name, default: default) }
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

    def <=>(other)
      unless (self.class <=> other.class) &&
        (self.identifier_names == other.identifier_names) &&
        self.identity? && other.identity?
        return nil
      end
      values_at(*identifier_names) <=> other.values_at(*identifier_names)
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
