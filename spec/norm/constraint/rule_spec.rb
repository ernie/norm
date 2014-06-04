require 'spec_helper'

module Norm
  module Constraint
    describe Rule do

      describe 'initialization' do

        it 'requires to: keyword' do
          error = proc { Rule.new(attr1: 'value') }.must_raise ArgumentError
          error.message.must_equal 'A to: parameter is required'
        end

        it 'requires at least one attribute' do
          error = proc { Rule.new(to: {name: "is empty"}) }.
            must_raise ArgumentError
          error.message.must_equal 'At least one attribute to match is required'
        end

        it 'initializes when requirements are met' do
          rule = Rule.new(attr1: 'zomg', to: {zomg: 'bbq'})
          rule.must_be_kind_of Rule
        end

      end

      describe 'with valid initialization params' do
        let(:params) {
          {
            to: {attr: "can't be blank", other_attr: "is invalid without attr"},
            type: :not_null, column_name: 'attr'
          }
        }
        let(:error_class) { Struct.new(:type, :column_name) }
        subject { Rule.new(params) }

        describe '#each' do

          it 'iterates through the mapped attributes' do
            subject.each.map { |k, v| [k, v] }.must_equal(
              [
                [:attr, "can't be blank"],
                [:other_attr, "is invalid without attr"]
              ]
            )
          end

        end

        describe '#===' do

          it 'matches against the public attributes of an object' do
            error = error_class.new(:not_null, 'attr')
            (subject === error).must_equal true
          end

          it 'matches with regular expressions' do
            error = error_class.new(:not_null, 'my_column_name')
            rule = Rule.new(params.merge(column_name: /column/))
            (rule === error).must_equal true
          end

        end

      end

    end
  end
end
