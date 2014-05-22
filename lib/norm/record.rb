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

    def inspect
      "#<#{self.class} #{attributes.inspect}>"
    end

    def get(*names)
      names.each_with_object({}) { |name, hash|
        hash[name] = send(name)
      }
    end

    def set(attributes)
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    def attribute_names
      @attribute_names ||= attributes.names
    end

    def values_at(*names, default: false)
      attributes.values_at(*names, default: false)
    end

    def all_attributes(default: false)
      attributes.all(default: default)
    end

    def initialized_attributes
      attributes.initialized
    end

    def identifying_attributes
      attributes.identifiers
    end

    def updated_attributes
      attributes.updated
    end

    def updated_attributes?
      attributes.updated?
    end

    def get_attributes(*attribute_names, default: false)
      attributes.get_attributes(*attribute_names, default: default)
    end

    def set_attributes(new_attributes)
      attributes.set_attributes(new_attributes)
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
      attributes.clear_updates!
      self
    end

    def updated!
      stored!
      attributes.clear_updates!
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
