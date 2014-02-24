require 'spec_helper'

class NormRecordSpecClass
  extend Norm::Record
end

class NormRecordSpecLoader
  def self.load(object, *args)
    object
  end
end

module Norm
  describe Record do

    let(:simple_record_class) {
      Class.new do
        extend Record

        attribute :name, NormRecordSpecLoader
        attribute :age,  NormRecordSpecLoader
      end
    }

    subject { NormRecordSpecClass }

    it 'creates an AttributeMethods module inside the extending class' do
      subject.ancestors.must_include subject::AttributeMethods
    end

    it 'creates another AttributeMethods module when inheriting' do
      subclass = Class.new(subject)
      subclass::AttributeMethods.wont_be_same_as subject::AttributeMethods
    end

    describe '.attribute_names' do

      it 'defaults to an empty array' do
        subject.attribute_names.must_equal []
      end

    end

    describe '#attribute_names' do

      it 'delegates to the class' do
        subject.stub(:attribute_names, ['zomg']) do
          subject.new.attribute_names.must_equal ['zomg']
        end
      end

    end

    describe '.attribute' do
      subject { Class.new { extend Record } }

      it 'adds the attribute name to #attribute_names as a string' do
        subject.attribute :my_attr, NormRecordSpecLoader
        subject.new.attribute_names.must_equal ['my_attr']
      end

      it 'alters only the locally-defined attribute names in a subclass' do
        subject.attribute :my_attr, NormRecordSpecLoader
        subclass = Class.new(subject)
        subclass.attribute :my_other_attr, NormRecordSpecLoader
        subclass_of_subclass = Class.new(subclass)
        subclass_of_subclass.attribute :yet_another_attr, NormRecordSpecLoader
        subject.attribute_names.must_equal ['my_attr']
        subclass.attribute_names.must_equal ['my_attr', 'my_other_attr']
        subclass_of_subclass.attribute_names.must_equal(
          ['my_attr', 'my_other_attr', 'yet_another_attr']
        )
      end

      it 'allows for later addition of parent class attributes' do
        subclass = Class.new(subject)
        subclass.attribute :my_attr, NormRecordSpecLoader
        subclass.attribute_names.must_equal ['my_attr']
        subject.attribute :parent_attr, NormRecordSpecLoader
        subclass.attribute_names.must_equal ['parent_attr', 'my_attr']
      end

      it 'creates an attribute reader' do
        subject.attribute :my_attr, NormRecordSpecLoader
        subject.new.must_respond_to :my_attr
      end

      it 'creates an attribute writer that uses the supplied loader' do
        loader = MiniTest::Mock.new
        loader.expect(:load, 'ZOMG LOADED', [1])
        subject.attribute :my_attr, loader
        record = subject.new
        record.my_attr = 1
        record.my_attr.must_equal 'ZOMG LOADED'
        loader.verify
      end

    end

    describe '#initialize' do
      subject { simple_record_class }

      it 'sets attributes from a hash' do
        record = subject.new(:name => 'Ernie Miller', :age => 36)
        record.name.must_equal 'Ernie Miller'
        record.age.must_equal 36
      end

      it 'sets attributes present on the record' do
        record = subject.new(:name => 'Ernie Miller', :langauge => 'Ruby')
        record.name.must_equal 'Ernie Miller'
        record.age.must_be_nil
      end

    end

    describe '#attributes' do
      subject { simple_record_class }

      it 'returns a hash of all record attribute names and values' do
        subject.new(:name => 'Ernie Miller').attributes.must_equal(
          'name' => 'Ernie Miller',
          'age'  => nil
        )
      end

    end

    describe '#initialized_attributes' do
      subject { simple_record_class }

      it 'returns a hash of all set attribute names and values' do
        subject.new(:name => 'Ernie Miller').initialized_attributes.must_equal(
          'name' => 'Ernie Miller'
        )
      end
    end

    describe '#updated_attributes' do
      subject { simple_record_class.new(:name => 'Ernie Miller', :age => 36) }

      it 'returns an empty hash just after initialization' do
        subject.updated_attributes.must_equal Hash.new
      end

      it 'captures changes' do
        subject.name = 'Bert Mueller'
        subject.updated_attributes.must_equal('name' => 'Bert Mueller')
      end

      it 'does not consider "changes" to the same value as updates' do
        subject.name = 'Ernie Miller'
        subject.updated_attributes.must_equal Hash.new
      end

      it 'removes updates that have returned to original value' do
        original_name = subject.name
        subject.name = 'Bert Mueller'
        subject.name = original_name
        subject.updated_attributes.must_equal Hash.new
      end
    end

    describe '#attributes=' do
      subject { simple_record_class }

      it 'sets the value of all attributes, not just the ones supplied' do
        record = subject.new(:name => 'Ernie Miller', :age => 36)
        record.attributes = {:name => 'Bert Mueller'}
        record.name.must_equal 'Bert Mueller'
        record.age.must_be_nil
      end
    end

    describe '#update_attributes' do
      subject { simple_record_class }

      it 'updates only attributes common between the record and hash' do
        record = subject.new(:name => 'Ernie Miller', :age => 36)
        record.update_attributes(:age => 37)
        record.name.must_equal 'Ernie Miller'
        record.age.must_equal 37
      end
    end

  end
end
