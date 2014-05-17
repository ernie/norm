module Norm
  module Identity

    def self.included(base)
      base.extend ClassMethods
    end

    def identifying_attribute_names
      []
    end

    def ==(other)
      !!(self.class <=> other.class) &&
        self.identity? && other.identity? &&
        identifying_attribute_names.all? { |attr|
          self.public_send(attr) == other.public_send(attr)
        }
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        self.identity? && other.identity? &&
        identifying_attribute_names.all? { |attr|
          self.public_send(attr).eql?(other.public_send(attr))
        }
    end

    def hash
      if identifying_attribute_names.any?
        self.class.hash ^
          identifying_attribute_names.
            inject(0) { |memo, attr| memo ^ send(attr) }
      else
        super
      end
    end

    def identity?
      identifying_attribute_names.any? &&
        identifying_attribute_names.none? { |attr| send(attr).nil? }
    end

    module ClassMethods

      def identity(*attrs)
        if attrs.empty?
          raise ArgumentError, 'Identity requires at least one attribute'
        end
        norm_identity_define_identifying_attribute_names(attrs)
      end

      def norm_identity_define_identifying_attribute_names(attrs)
        attrs = attrs.map(&:to_s)
        define_method(:identifying_attribute_names) { attrs }
      end

    end

  end
end
