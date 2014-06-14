require 'spec_helper'

module Norm
  module Constraint
    describe RuleSet do
      let(:error_class) { Struct.new(:type, :column_name, :constraint_name) }
      let(:not_null_error) { error_class.new(:not_null, 'username', nil) }
      let(:check_error) { error_class.new(:check, nil, 'username_length') }
      let(:fk_error) { error_class.new(:foreign_key, 'id', nil) }

      subject { RuleSet.new }

      describe 'initialization' do

        it 'initializes with a prebuilt array of rules' do
          RuleSet.new([1, 2, 3]).rules.must_equal [1, 2, 3]
        end

        it 'does not reuse the same array passed in' do
          rules = [1, 2, 3]
          ruleset = RuleSet.new(rules)
          rules << 4
          ruleset.rules.size.must_equal 3
        end

      end

      describe '#map' do

        it 'adds rules to the RuleSet' do
          subject.map(
            type: :not_null, column_name: 'username',
            to: { username: "can't be blank" }
          )
          subject.rules.size.must_equal 1
        end

      end

      describe '#+' do
        let(:ruleset1) {
          RuleSet.new.tap { |rs|
            rs.map(
              type: :not_null, column_name: 'username',
              to: { username: "can't be blank" }
            )
          }
        }
        let(:ruleset2) {
          RuleSet.new.tap { |rs|
            rs.map(
              type: :check, constraint_name: 'username_length',
              to: { username: "must be between 3 and 16 characters" }
            )
          }
        }

        it 'returns a new ruleset with the rules from both sets' do
          new_ruleset = ruleset1 + ruleset2
          new_ruleset.rules.must_equal ruleset1.rules + ruleset2.rules
        end

      end

      describe '#match' do
        subject {
          RuleSet.new.tap do |rules|
            rules.map(
              type: :not_null, column_name: 'username',
              to: { username: "can't be blank" }
            )
            rules.map(
              type: :check, constraint_name: 'username_length',
              to: { username: "must be between 3 and 32 characters" }
            )
          end
        }

        it 'finds a matching rule for an error' do
          rule = subject.match(not_null_error)
          Hash[rule.each.map { |k, v| [k, v] }].must_equal(
            username: "can't be blank"
          )
          rule = subject.match(check_error)
          Hash[rule.each.map { |k, v| [k, v] }].must_equal(
            username: "must be between 3 and 32 characters"
          )
        end

        it 'returns nil if no match' do
          subject.match(fk_error).must_be_nil
        end

      end

    end
  end
end
