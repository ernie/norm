module Norm
  module Record

    def self.extended(mod)
      mod.include InstanceMethods
      mod.local_attribute_names
      mod.attribute_methods_module
    end

    def inherited(klass)
      klass.local_attribute_names
      klass.attribute_methods_module
      klass.extend AttributeNames
    end

    def local_attribute_names
      @local_attribute_names ||= []
    end
    alias :attribute_names :local_attribute_names

    def attribute_methods_module
      @attribute_methods_module ||= const_set(
          :AttributeMethods, Module.new
        ).tap { |mod| include mod }
    end

    def attribute(name, loader)
      @local_attribute_names |= [name.to_s]
      attribute_methods_module.module_eval {
        attr_reader name
        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", loader.load(value))
        end
      }
    end

    module AttributeNames
      def attribute_names
        superclass.attribute_names | local_attribute_names
      end
    end

    module InstanceMethods

      def attribute_names
        self.class.attribute_names
      end

    end

  end
end
