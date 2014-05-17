module Norm
  class Record
    include Identity

    identity :id

    Attr = Attribute = Norm::Attribute

    class << self

      @attribute_loader = Attribute::Loader.new
      attr_reader :attribute_loader
      protected :attribute_loader

      def inherited(klass)
        klass.inherit_attribute_loader(attribute_loader)
        klass.attribute_methods_module
      end

      def attribute_names
        []
      end

      def inherit_attribute_loader(inherited)
        @attribute_loader = Attribute::Loader.new(inherited)
      end

      def local_attribute_loaders
        @local_attribute_loaders ||= {}
      end
      alias :attribute_loaders :local_attribute_loaders

      def attribute_methods_module
        @attribute_methods_module ||= const_set(
            :AttributeMethods, Module.new
          ).tap { |mod| include mod }
      end

      def attribute(name, loader)
        attribute_methods_module.module_eval {
          attr_reader name
          define_method("#{name}=") do |value|
            write_attribute(name, value)
          end
        }
        name = name.to_s
        current_attribute_names = attribute_names | [name]
        define_singleton_method(:attribute_names) {
          super() | current_attribute_names
        }
        attribute_loader.set_loader(name, loader)
      end

      def load_attribute(name, value)
        attribute_loader.load(name, value)
      end

      def from_repo(attributes)
        new(attributes).tap { |record| record.stored! }
      end

    end

    def initialize(attributes = {})
      @_initialized_attributes = Hash.new { |h, k| h[k] = true }
      reset_updated_attributes!
      set_attributes(attributes)
      track_attribute_updates!
    end

    def inspect
      "#<#{self.class} #{
        attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
      }>"
    end

    def attribute_names
      self.class.attribute_names
    end

    def identifying_attributes
      read_attributes(*identifying_attribute_names)
    end

    def identifying_attribute_values
      values_at(*identifying_attribute_names)
    end

    def values_at(*attribute_names)
      attribute_names.map! { |name| send(name) }
    end

    def attribute?(name)
      attribute_names.include?(name.to_s)
    end

    def attributes
      read_attributes(*attribute_names)
    end

    def initialized_attribute_names
      attribute_names & @_initialized_attributes.keys
    end

    def updated_attribute_names
      attribute_names & @_updated_attributes.keys
    end

    def initialized_attributes
      read_attributes(*initialized_attribute_names)
    end

    def updated_attributes
      read_attributes(*updated_attribute_names)
    end

    def updated_attributes?
      updated_attribute_names.any?
    end

    def read_attributes(*attribute_names)
      attribute_names.each_with_object({}) { |k, h| h[k] = send(k) }
    end

    def set_attributes(attributes)
      attributes = normalize_attributes(attributes)
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
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
      reset_updated_attributes!
      self
    end

    def updated!
      stored!
      reset_updated_attributes!
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

    private

    def reset_updated_attributes!
      @_updated_attributes = Hash.new { |h, k| h[k] = [send(k), nil] }
    end

    def track_attribute_updates!
      @_track_attribute_updates = true
    end

    def tracking_attribute_updates?
      @_track_attribute_updates == true
    end

    def attribute_loaders
      @_attribute_loaders ||= self.class.attribute_loaders
    end

    def load_attribute(name, value)
      self.class.load_attribute(name, value)
    end

    def write_attribute(name, value)
      name = name.to_s
      to_write = load_attribute(name, value)
      attribute_initializing(name)
      attribute_updating(name, to_write)
      instance_variable_set("@#{name}", to_write)
    end

    def attribute_initializing(name)
      @_initialized_attributes[name]
    end

    def attribute_updating(name, value)
      if tracking_attribute_updates?
        changes = @_updated_attributes[name]
        changes[1] = value
        @_updated_attributes.delete(name) if changes.first == changes.last
      end
    end

    def normalize_attributes(attributes)
      attributes.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
    end

  end
end
