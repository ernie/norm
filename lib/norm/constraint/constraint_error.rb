module Norm
  module Constraint
    class ConstraintError < Error

      class NullResult
        def error_field(name)
          nil
        end
      end

      TYPES = {
        PG::RestrictViolation   => :restrict,
        PG::NotNullViolation    => :not_null,
        PG::ForeignKeyViolation => :foreign_key,
        PG::UniqueViolation     => :unique,
        PG::CheckViolation      => :check,
        PG::ExclusionViolation  => :exclusion
      }

      attr_reader :error, :result

      def initialize(error, message = 'Norm::Constraint::ConstraintError')
        @error, @result = error, error.result || NullResult.new
        super(message)
      end

      def type
        TYPES[error.class]
      end

      PG.constants.map(&:to_s).select { |name|
        name.start_with? 'PG_DIAG_'
      }.each do |name|
        field = PG.const_get(name)
        name = name.sub(/\APG_DIAG_/, '').downcase
        define_method(name) { result.error_field(field) }
      end

    end
  end
end
