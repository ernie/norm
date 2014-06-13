require 'spec_helper'

module Norm
  describe RecordDelegator do
    let(:person_record_class) {
      Class.new(Record) {
        attribute :id,   Attr::Integer
        attribute :name, Attr::String
        attribute :age,  Attr::Integer
      }
    }
    let(:delegator_class) {
      record_class = person_record_class
      Class.new { include Norm::RecordDelegator(record_class) }
    }
    subject { delegator_class }

    describe 'generated module' do

      it 'adds a __record_class__ class method' do
        subject.__record_class__.must_be_same_as person_record_class
      end

      it 'adds a __record_class__ instance method' do
        subject.new.__record_class__.must_be_same_as person_record_class
      end

      it 'aliases __record_class__ to record_class' do
        subject.record_class.must_be_same_as person_record_class
        subject.new.record_class.must_be_same_as person_record_class
      end

      it 'includes Norm::RecordDelegator into base' do
        subject.ancestors.must_include Norm::RecordDelegator
      end

    end

    describe '.collection_class' do

      it 'is Collection by default' do
        subject.collection_class.must_equal Record::Collection
      end

    end

    describe '.collection' do

      it 'returns a new collection with a matching record class' do
        subject.collection([]).record_class.must_equal subject
      end

    end

    describe '.constraints' do
      it 'allows addition of constraint rules' do
        subject.constraints do |rule|
          rule.must_be_kind_of Constraint::RuleSet
        end
      end

      it 'defines constraint_rule_for to match against the new RuleSet' do
        subject.constraints do |rule|
          rule.map type: :not_null, to: {base: 'ZOMG NOT NULL CONSTRAINT!!!'}
        end
        error = MiniTest::Mock.new
        error.expect(:type, :not_null)
        rule = subject.new.constraint_rule_for(error)
        rule.each.to_a.must_equal [[:base, 'ZOMG NOT NULL CONSTRAINT!!!']]
        error.verify
      end
    end

    describe '.from_repo' do

      it 'instantiates with a stored record' do
        delegator = subject.from_repo(:id => 1, :name => 'Ernie')
        delegator.must_be :stored?
        delegator.id.must_equal 1
        delegator.name.must_equal 'Ernie'
      end

    end

    describe '.with_identifiers' do

      it 'creates a new delegator with the identity provided in arguments' do
        subject.identity :name, :age
        delegator = subject.with_identifiers('Ernie', '36')
        delegator.must_be_kind_of Norm::RecordDelegator
        delegator.name.must_equal 'Ernie'
        delegator.age.must_equal 36
      end

    end


    describe 'initialization' do

      it 'creates the instance with a record containing the given attributes' do
        delegator = subject.new(:name => 'Ernie', :age => 36)
        delegator.record.must_be_kind_of person_record_class
        delegator.name.must_equal 'Ernie'
        delegator.age.must_equal 36
      end

      it 'yields itself and not the record when initialized with a block' do
        subject.send(:define_method, :flanderized_name=) { |name|
          self.name = name.sub(/-diddly\z/, '')
        }
        delegator = subject.new(:age => 36) do |person|
          person.flanderized_name = 'Ernie-diddly'
        end
        delegator.name.must_equal 'Ernie'
      end

    end

    describe 'overridden methods' do
      subject { delegator_class.new(:name => 'Ernie', :age => 36) }

      describe '#get' do

        it 'gets attributes using delegator accessors' do
          delegator_class.send(:define_method, :flanderized_name) {
            "#{name}-diddly"
          }
          subject.get(:flanderized_name).must_equal(
            :flanderized_name => 'Ernie-diddly'
          )
        end

      end

      describe '#set' do

        it 'sets attributes using delegator accessors' do
          delegator_class.send(:define_method, :flanderized_name=) { |name|
            self.name = name.sub(/-diddly\z/, '')
          }
          subject.set(:flanderized_name => 'Bert-diddly')
          subject.name.must_equal 'Bert'
        end

        it 'returns self, so it can be chained after object creation' do
          subject.set(:id => 1).must_be_same_as subject
        end

      end

      describe '#set_attributes' do

        it 'sets attributes on the underlying record' do
          delegator_class.send(:define_method, :name=) { |name|
            __record__.name = "#{name}-diddly"
          }
          subject.set_attributes(:name => 'Bert')
          subject.name.must_equal 'Bert'
        end

        it 'returns self, for chainability and consistency with Record API' do
          subject.set_attributes(:id => 1).must_be_same_as subject
        end

      end

    end

  end
end
