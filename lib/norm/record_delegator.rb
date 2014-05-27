module Norm
  module RecordDelegator

    def self.included(base)
      base.extend ClassMethods
    end

    attr_reader :__record__
    alias       :record :__record__

    def initialize(attributes = {})
      if block_given?
        record_class.new(attributes) do |record|
          @__record__ = record
          yield self
        end
      else
        @__record__ = record_class.new(attributes)
      end
    end

    def respond_to_missing?(method_id, include_private = false)
      __record__.respond_to?(method_id, include_private) or super
    end

    def method_missing(method_id, *args, &block)
      if __record__.respond_to?(method_id)
        __record__.send(method_id, *args, &block)
      else
        super
      end
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
      self
    end

    def set_attributes(attributes)
      __record__.set_attributes(attributes)
      self
    end

    def ==(other)
      !!(self.class <=> other.class) &&
        self.__record__ == other.__record__
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        self.__record__.eql?(other.__record__)
    end

    def hash(other)
      self.class.hash ^ self.__record__.hash
    end

    module ClassMethods

      def from_repo(attributes)
        new(attributes).tap { |record| record.stored! }
      end

      def respond_to_missing?(method_id, include_private = false)
        record_class.respond_to?(method_id, include_private) or super
      end

      def method_missing(method_id, *args, &block)
        if record_class.respond_to?(method_id)
          record_class.send(method_id, *args, &block)
        else
          super
        end
      end

    end

  end

  def self.RecordDelegator(klass)
    mod = Module.new {
      define_singleton_method(:included) { |base|
        base.class_eval {
          define_method(:record_class) { klass }
          define_singleton_method(:record_class) { klass }
          include RecordDelegator
        }
      }
    }
    mod
  end

end
