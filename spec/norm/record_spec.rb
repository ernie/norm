require 'spec_helper'

class NormRecordSpecClass
  extend Norm::Record
end

module Norm
  describe Record do
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
        subject.attribute :my_attr, nil
        subject.new.attribute_names.must_equal ['my_attr']
      end

      it 'alters only the locally-defined attribute names in a subclass' do
        subject.attribute :my_attr, nil
        subclass = Class.new(subject)
        subclass.attribute :my_other_attr, nil
        subclass_of_subclass = Class.new(subclass)
        subclass_of_subclass.attribute :yet_another_attr, nil
        subject.attribute_names.must_equal ['my_attr']
        subclass.attribute_names.must_equal ['my_attr', 'my_other_attr']
        subclass_of_subclass.attribute_names.must_equal(
          ['my_attr', 'my_other_attr', 'yet_another_attr']
        )
      end

      it 'allows for later addition of parent class attributes' do
        subclass = Class.new(subject)
        subclass.attribute :my_attr, nil
        subclass.attribute_names.must_equal ['my_attr']
        subject.attribute :parent_attr, nil
        subclass.attribute_names.must_equal ['parent_attr', 'my_attr']
      end

      it 'creates an attribute reader' do
        subject.attribute :my_attr, nil
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

  end
end
