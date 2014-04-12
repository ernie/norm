module Norm
  module Identity

    def identity(*attrs)
      if attrs.empty?
        raise ArgumentError, 'Identity requires at least one attribute'
      end
      norm_identity_define_equivalence(attrs)
      norm_identity_define_equality(attrs)
      norm_identity_define_hash(attrs)
      norm_define_identity_predicate(attrs)
    end

    private

    def norm_identity_define_equivalence(attrs)
      define_method(:==) { |other|
        !!(self.class <=> other.class) &&
          self.identity? && other.identity? &&
          attrs.all? { |attr|
            self.public_send(attr) == other.public_send(attr)
          }
      }
    end

    def norm_identity_define_equality(attrs)
      define_method(:eql?) { |other|
        self.class.eql?(other.class) &&
          self.identity? && other.identity? &&
          attrs.all? { |attr|
            self.public_send(attr).eql?(other.public_send(attr))
          }
      }
    end

    def norm_identity_define_hash(attrs)
      define_method(:hash) {
        self.class.hash ^
          attrs.inject(0) { |memo, attr| memo ^ send(attr) }
      }
    end

    def norm_define_identity_predicate(attrs)
      define_method(:identity?) {
        attrs.none? { |attr| send(attr).nil? }
      }
    end

  end
end
