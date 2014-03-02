module Norm
  module Record

    def self.extended(mod)
      mod.include InstanceMethods
      mod.local_attribute_loaders
      mod.attribute_methods_module
    end

    def inherited(klass)
      klass.local_attribute_loaders
      klass.attribute_methods_module
      klass.extend SubclassExtensions
    end

    def local_attribute_loaders
      @local_attribute_loaders ||= {}
    end
    alias :attribute_loaders :local_attribute_loaders

    def local_attribute_names
      local_attribute_loaders.keys
    end
    alias :attribute_names :local_attribute_names

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
      @local_attribute_loaders[name.to_s] = loader
    end

    def primary_keys=(attrs)
      keys = Array(attrs).map(&:to_s)
      define_singleton_method(:primary_keys) { keys }
    end

    def primary_keys
      ['id']
    end

    def table_name=(name)
      define_singleton_method(:table_name) { name }
    end

    def table_name
      raise 'zomg'
    end

    def new_from_db(attributes)
      new(attributes).tap { |record| record.stored! }
    end

    def fetch_sql
      <<-SQL
        select * from #{table_name}
        where #{primary_keys.map { |k| "#{k} = %{#{k}}" }.join(' AND ')}
        limit 1
      SQL
    end

    def fetch_statement(*args)
      Statement.select(fetch_sql, Hash[primary_keys.zip(args)])
    end

    def fetch(*args)
      Norm.with_connection do |conn|
        conn.exec_statement(fetch_statement(*args)) do |result|
          record = result.first
          new_from_db(record) if record
        end
      end
    end

    def insert_sql
      <<-SQL
        insert into #{table_name} (&{param_keys}) values (&{param_values})
        returning *
      SQL
    end

    def insert_statement(record)
      Statement.insert(insert_sql, record.initialized_attributes)
    end

    def insert(record)
      Norm.with_connection do |conn|
        conn.exec_statement(insert_statement(record)) do |result|
          attributes = result.first
          record.reset_attributes!(attributes)
          record.stored!
        end
      end
    end

    def update_sql
      <<-SQL
        update #{table_name} set &{param_sets}
        returning *
      SQL
    end

    def update_statement(record)
      Statement.update(update_sql, record.updated_attributes)
    end

    def update(record)
      Norm.with_connection do |conn|
        conn.new.exec_statement(update_statement(record)) do |result|
          attributes = result.first
          record.reset_attributes!(attributes)
          record.stored!
        end
      end
    end

    module SubclassExtensions

      def attribute_names
        superclass.attribute_names | local_attribute_names
      end

      def attribute_loaders
        superclass.attribute_loaders.merge local_attribute_loaders
      end

    end

    module InstanceMethods

      Attr = Attribute = Norm::Attribute

      def initialize(attributes = {})
        @_initialized_attributes = Hash.new { |h, k| h[k] = true }
        reset_updated_attributes!
        set_attributes(attributes)
        track_attribute_updates!
      end

      def attribute_names
        self.class.attribute_names
      end

      def attributes
        read_attributes(attribute_names)
      end

      def reset_attributes!(attributes = {})
        self.attributes = attributes
        reset_updated_attributes!
        self
      end

      def initialized_attribute_names
        @_initialized_attributes.keys
      end

      def updated_attribute_names
        @_updated_attributes.keys
      end

      def initialized_attributes
        read_attributes(initialized_attribute_names)
      end

      def updated_attributes
        read_attributes(updated_attribute_names)
      end

      def read_attributes(attribute_names)
        attribute_names.each_with_object({}) { |k, h| h[k] = send(k) }
      end

      def attributes=(attributes)
        attributes = normalize_attributes(attributes)
        attribute_names.each do |attr_name|
          send("#{attr_name}=", attributes[attr_name])
        end
      end

      def set_attributes(attributes)
        attributes = normalize_attributes(attributes)
        (attribute_names & attributes.keys).each do |attr_name|
          send("#{attr_name}=", attributes[attr_name])
        end
      end

      def store
        result = stored? ? update : insert
        !!result
      end

      def insert
        self.class.insert(self)
      end

      def update
        self.class.update(self)
      end

      def stored!
        @_stored = true
        self
      end

      def stored?
        @_stored == true
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
        attribute_loaders[name].load(value)
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
end
