require 'spec_helper'

NormRecordSpecClass = Class.new(Norm::Record)

class NormRecordSpecLoader
  def self.load(object, *args)
    object
  end
end

module Norm
  describe Record do

    let(:simple_record_class) {
      Class.new(Record) do
        attribute :name, NormRecordSpecLoader
        attribute :age,  NormRecordSpecLoader
      end
    }

    subject { NormRecordSpecClass }

    it 'creates an AttributeMethods module inside the inheriting class' do
      subject.ancestors.must_include subject::AttributeMethods
    end

    it 'creates another AttributeMethods module when subclassing the class' do
      subclass = Class.new(subject)
      subclass::AttributeMethods.wont_be_same_as subject::AttributeMethods
    end

    describe '.attribute_names' do

      it 'defaults to an empty array' do
        subject.attribute_names.must_equal []
      end

    end

    describe '.attribute' do
      subject { Class.new(Record) }

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

    describe 'initialization' do
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

      it 'creates an unstored, undeleted record' do
        record = subject.new
        record.wont_be :stored?
        record.wont_be :deleted?
      end

    end

    describe 'instance methods' do
      subject { simple_record_class.new }

      describe '#attribute_names' do

        it 'delegates to the class implementation by default' do
          simple_record_class.stub(:attribute_names, ['zomg']) do
            subject.attribute_names.must_equal ['zomg']
          end
        end

      end

      describe '#attribute_values' do

        it 'returns an array of values in the specified order' do
          record = simple_record_class.new(:name => 'Ernie', :age => 36)
          record.attribute_values(:age, :name).must_equal [36, 'Ernie']
        end

      end

      describe '#attribute?' do

        it 'tells if the record contains this attribute' do
          subject.attribute?(:name).must_equal true
          subject.attribute?(:foo).must_equal false
        end

      end

      describe '#attributes' do

        it 'returns a hash of all record attribute names and values' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.attributes.must_equal(
            'name' => 'Ernie Miller',
            'age'  => nil
          )
        end

      end

      describe '#initialized_attribute_names' do

        it 'tells all attributes that have had a value set' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.initialized_attribute_names.must_equal ['name']
        end

      end

      describe '#initialized_attributes' do

        it 'returns a hash of all set attribute names and values' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.initialized_attributes.must_equal(
            'name' => 'Ernie Miller'
          )
        end

      end

      describe '#updated_attribute_names' do

        it 'tells all attributes that have been updated from initial value' do
          subject.name = 'Bob'
          subject.updated_attribute_names.must_equal ['name']
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

      describe '#read_attributes' do

        it 'returns a hash of requested attributes using symbols' do
          record = simple_record_class.new(:name => 'Ernie')
          record.read_attributes(:name, :age).must_equal(
            :name => 'Ernie', :age => nil
          )
        end

        it 'returns a hash of requested attributes using strings' do
          record = simple_record_class.new(:name => 'Ernie')
          record.read_attributes('name', 'age').must_equal(
            'name' => 'Ernie', 'age' => nil
          )
        end

        it 'does not filter list of requested attributes' do
          record = simple_record_class.new(:name => 'Ernie', :age => 36)
          proc { record.read_attributes(:name, :age, :favorite_color) }.
            must_raise NoMethodError
        end

      end

      describe '#set_attributes' do

        it 'updates only attributes common between the record and hash' do
          record = simple_record_class.new(:name => 'Ernie Miller', :age => 36)
          record.set_attributes(:age => 37)
          record.name.must_equal 'Ernie Miller'
          record.age.must_equal 37
        end

      end

      describe '#stored?' do

        it 'returns false on new records' do
          subject.wont_be :stored?
        end

        it 'returns true on inserted records' do
          subject.inserted!
          subject.must_be :stored?
        end

      end

      describe 'stored!' do

        it 'tells object to consider itself stored' do
          subject.wont_be :stored?
          subject.stored!
          subject.must_be :stored?
        end

      end

      describe 'inserted!' do

        it 'sets the record as stored' do
          subject.wont_be :stored?
          subject.inserted!
          subject.must_be :stored?
        end

        it 'tells the record it no longer has updated attributes' do
          subject.name = 'Ernie'
          subject.updated_attribute_names.must_equal ['name']
          subject.inserted!
          subject.updated_attribute_names.must_be :empty?
        end

      end

      describe 'updated!' do

        it 'sets the record as stored' do
          subject.wont_be :stored?
          subject.updated!
          subject.must_be :stored?
        end

        it 'tells the record it no longer has updated attributes' do
          subject.name = 'Ernie'
          subject.updated_attribute_names.must_equal ['name']
          subject.updated!
          subject.updated_attribute_names.must_be :empty?
        end

      end

      describe 'deleted?' do

        it 'is false for new records' do
          subject.wont_be :deleted?
        end

        it 'is true when a record has received the deleted! message' do
          subject.deleted!
          subject.must_be :deleted?
        end

      end

      describe 'deleted!' do

        it 'sets the record as not stored' do
          subject.inserted!
          subject.must_be :stored?
          subject.deleted!
          subject.wont_be :stored?
        end

        it 'sets the record as deleted' do
          subject.deleted!
          subject.must_be :deleted?
        end

      end

    end

  end
end
