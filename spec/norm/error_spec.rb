require 'spec_helper'

module Norm

  describe Error do

    it 'is a StandardError' do
      Error.new.must_be_kind_of StandardError
    end

  end

  describe ConnectionResetError do

    it 'is an Error' do
      ConnectionResetError.new.must_be_kind_of Error
    end

  end

  describe ConstraintError do

    class BogusResult
      MAP = Hash[
        [
          PG::PG_DIAG_COLUMN_NAME,
          PG::PG_DIAG_SCHEMA_NAME,
          PG::PG_DIAG_CONSTRAINT_NAME,
          PG::PG_DIAG_SEVERITY,
          PG::PG_DIAG_CONTEXT,
          PG::PG_DIAG_SOURCE_FILE,
          PG::PG_DIAG_DATATYPE_NAME,
          PG::PG_DIAG_SOURCE_FUNCTION,
          PG::PG_DIAG_INTERNAL_POSITION,
          PG::PG_DIAG_SOURCE_LINE,
          PG::PG_DIAG_INTERNAL_QUERY,
          PG::PG_DIAG_SQLSTATE,
          PG::PG_DIAG_MESSAGE_DETAIL,
          PG::PG_DIAG_STATEMENT_POSITION,
          PG::PG_DIAG_MESSAGE_HINT,
          PG::PG_DIAG_TABLE_NAME,
          PG::PG_DIAG_MESSAGE_PRIMARY
        ].map { |constant|
          [constant, constant]
        }
      ]

      def error_field(constant)
        MAP[constant]
      end
    end

    let(:not_null_violation) { PG::NotNullViolation.new }
    subject { ConstraintError.new(not_null_violation) }

    it 'requires an error as first parameter' do
      proc { ConstraintError.new }.must_raise ArgumentError
      ConstraintError.new(not_null_violation).
        must_be_kind_of ConstraintError
    end

    it 'is an Error' do
      subject.must_be_kind_of Error
    end

    it 'provides readers for PG:Error result error fields' do
      subject.column_name.must_be_nil
      subject.constraint_name.must_be_nil
      subject.context.must_be_nil
      subject.datatype_name.must_be_nil
      subject.internal_position.must_be_nil
      subject.internal_query.must_be_nil
      subject.message_detail.must_be_nil
      subject.message_hint.must_be_nil
      subject.message_primary.must_be_nil
      subject.schema_name.must_be_nil
      subject.severity.must_be_nil
      subject.source_file.must_be_nil
      subject.source_function.must_be_nil
      subject.source_line.must_be_nil
      subject.sqlstate.must_be_nil
      subject.statement_position.must_be_nil
      subject.table_name.must_be_nil
    end

    it 'reads error fields from the result object' do
      not_null_violation.stub(:result, BogusResult.new) do
        subject.column_name.must_equal PG::PG_DIAG_COLUMN_NAME
        subject.constraint_name.must_equal PG::PG_DIAG_CONSTRAINT_NAME
        subject.context.must_equal PG::PG_DIAG_CONTEXT
        subject.datatype_name.must_equal PG::PG_DIAG_DATATYPE_NAME
        subject.internal_position.must_equal PG::PG_DIAG_INTERNAL_POSITION
        subject.internal_query.must_equal PG::PG_DIAG_INTERNAL_QUERY
        subject.message_detail.must_equal PG::PG_DIAG_MESSAGE_DETAIL
        subject.message_hint.must_equal PG::PG_DIAG_MESSAGE_HINT
        subject.message_primary.must_equal PG::PG_DIAG_MESSAGE_PRIMARY
        subject.schema_name.must_equal PG::PG_DIAG_SCHEMA_NAME
        subject.severity.must_equal PG::PG_DIAG_SEVERITY
        subject.source_file.must_equal PG::PG_DIAG_SOURCE_FILE
        subject.source_function.must_equal PG::PG_DIAG_SOURCE_FUNCTION
        subject.source_line.must_equal PG::PG_DIAG_SOURCE_LINE
        subject.sqlstate.must_equal PG::PG_DIAG_SQLSTATE
        subject.statement_position.must_equal PG::PG_DIAG_STATEMENT_POSITION
        subject.table_name.must_equal PG::PG_DIAG_TABLE_NAME
      end
    end

  end

end
