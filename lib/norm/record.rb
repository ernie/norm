module Norm
  class Record

    attr_reader :attributes

    Attr = Attribute = Norm::Attribute

    @attributes_class = Attributes = ::Norm::Attributes.dup

    class << self

      attr_reader :attributes_class
      private :attributes_class

      def identity(*args)
        attributes_class.identity(*args)
      end

      def inherited(klass)
        klass.inherit_attributes_class(attributes_class)
        klass.attribute_methods_module
      end

      def attribute_names
        attributes_class.names
      end

      def identifying_attribute_names
        attributes_class.identifier_names
      end

      def with_identifiers(*keys)
        new(Hash[identifying_attribute_names.zip(keys)])
      end

      def inherit_attributes_class(klass)
        @attributes_class ||= const_set(:Attributes, Class.new(klass))
      end

      def attribute_methods_module
        @attribute_methods_module ||= const_set(
            :AttributeMethods, Module.new
          ).tap { |mod| include mod }
      end

      def attribute(name, loader)
        attributes_class.attribute(name, loader)
        attribute_methods_module.module_eval {
          define_method("#{name}") do |default: false|
            attributes[name, default: default]
          end
          define_method("#{name}=") do |value|
            attributes[name] = value
          end
        }
      end

      def from_repo(attributes)
        new(attributes).tap { |record| record.stored! }
      end

      def constraints
        rules = Constraint::RuleSet.new
        yield rules
        define_method(:constraint_rule_for) { |error|
          rules.match(error) || super(error)
        }
      end

    end

    identity :id

    def initialize(attributes = {})
      if block_given?
        self.class::Attributes.new(attributes) { |attrs|
          @attributes = attrs
          yield self
        }
      else
        @attributes = self.class::Attributes.new(attributes)
      end
    end

    def constraint_rule_for(error)
      nil
    end

    def constraint_error!(error)
      false
    end

    def inspect
      "#<#{self.class} #{attributes.inspect}>"
    end

    def get(*names)
      names.each_with_object({}) { |name, hash|
        hash[name] = public_send(name)
      }
    end

    def set(attributes)
      attributes.each do |name, value|
        public_send("#{name}=", value) if respond_to?("#{name}=")
      end
      self
    end

    def attribute_names
      attributes.names
    end

    def identifying_attribute_names
      attributes.identifier_names
    end

    def attribute_values_at(*names, default: false)
      attributes.values_at(*names, default: default)
    end

    def values_at(*names)
      names.map { |name| public_send(name) }
    end

    def all_attributes(default: false)
      attributes.all(default: default)
    end

    def initialized_attributes(default: false)
      attributes.initialized(default: default)
    end

    def identifying_attributes
      attributes.identifiers
    end

    def updated_attributes(default: false)
      attributes.updated(default: default)
    end

    def updated_attributes?
      attributes.updated?
    end

    def get_attributes(*attribute_names, default: false)
      attributes.get_attributes(*attribute_names, default: default)
    end

    def get_original_attributes(*attribute_names, default: false)
      attributes.get_originals(*attribute_names, default: default)
    end

    def set_attributes(new_attributes)
      attributes.set_attributes(new_attributes)
      self
    end

    def stored!
      @_stored  = true
      @_deleted = false
      self
    end

    def stored?
      @_stored == true
    end

    def inserted!
      stored!
      attributes.commit!
      self
    end

    def updated!
      stored!
      attributes.commit!
      self
    end

    def deleted!
      @_stored  = false
      @_deleted = true
      self
    end

    def deleted?
      @_deleted == true
    end

    def ==(other)
      !!(self.class <=> other.class) &&
        self.attributes == other.attributes
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        self.attributes.eql?(other.attributes)
    end

    def hash
      self.class.hash ^ self.attributes.hash
    end

  end
end
