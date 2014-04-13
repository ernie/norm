require 'spec_helper'

module Norm
  describe Record do

    let(:simple_record_class) {
      Class.new(Record) do
        attribute :id,   Attr::Integer
        attribute :name, Attr::String
        attribute :age,  Attr::Integer
      end
    }

    subject { Class.new(Norm::Record) }

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

      it 'adds the attribute name to .attribute_names as a string' do
        subject.attribute :my_attr, Attr::String
        subject.attribute_names.must_equal ['my_attr']
      end

      it 'adds the attribute name to #attribute_names as a string' do
        subject.attribute :my_attr, Attr::String
        subject.new.attribute_names.must_equal ['my_attr']
      end

      it 'alters only the locally-defined attribute names in a subclass' do
        subject.attribute :my_attr, Attr::String
        subclass = Class.new(subject)
        subclass.attribute :my_other_attr, Attr::String
        subclass_of_subclass = Class.new(subclass)
        subclass_of_subclass.attribute :yet_another_attr, Attr::String
        subject.attribute_names.must_equal ['my_attr']
        subclass.attribute_names.must_equal ['my_attr', 'my_other_attr']
        subclass_of_subclass.attribute_names.must_equal(
          ['my_attr', 'my_other_attr', 'yet_another_attr']
        )
      end

      it 'allows for later addition of parent class attributes' do
        subclass = Class.new(subject)
        subclass.attribute :my_attr, Attr::String
        subclass.attribute_names.must_equal ['my_attr']
        subject.attribute :parent_attr, Attr::String
        subclass.attribute_names.must_equal ['parent_attr', 'my_attr']
      end

      it 'creates an attribute reader' do
        subject.attribute :my_attr, Attr::String
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

    describe '.load_attribute' do

      it 'loads the attribute using the class attribute loader' do
        loader = MiniTest::Mock.new
        loader.expect(:load, 'ZOMG LOADED', [1])
        subject.attribute :my_attr, loader
        value = subject.load_attribute 'my_attr', 1
        value.must_equal 'ZOMG LOADED'
        loader.verify
      end

    end

    describe '.identity' do
      subject {
        Class.new(Record) {
          attribute :id,   Attr::Integer
          attribute :name, Attr::String
          attribute :age,  Attr::Integer
        }
      }

      it 'requires at least one attribute name' do
        proc { subject.identity }.must_raise ArgumentError
      end

      it 'sets .identifying_attribute_names to stringified params' do
        subject.identity :name, :age
        subject.identifying_attribute_names.must_equal ['name', 'age']
      end

      it 'is available as .identifier' do
        subject.identity :id
        subject.identifying_attribute_names.must_equal ['id']
      end

    end

    describe '.identifying_attribute_names' do

      it 'defaults to id' do
        subject.identifying_attribute_names.must_equal ['id']
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

      describe '#inspect' do

        it 'returns a legible string listing object attributes' do
          subject.name, subject.age = 'Ernie', 36
          subject.inspect.must_match(
            /\A#<#<Class:.*?> id: nil, name: "Ernie", age: 36>\z/
          )
        end

      end

      describe '#attribute_names' do

        it 'delegates to the class implementation by default' do
          simple_record_class.stub(:attribute_names, ['zomg']) do
            subject.attribute_names.must_equal ['zomg']
          end
        end

      end

      describe '#identifying_attribute_names' do

        it 'delegates to the class implementation by default' do
          simple_record_class.stub(:identifying_attribute_names, ['zomg']) do
            subject.identifying_attribute_names.must_equal ['zomg']
          end
        end

      end

      describe '#identifying_attributes' do

        it 'returns a hash of identifying attribute keys and values' do
          subject.id = 42
          subject.identifying_attributes.must_equal('id' => 42)
        end

      end

      describe '#identifying_attribute_values' do

        it 'returns an array of identifying attribute values' do
          subject.id = 42
          subject.identifying_attribute_values.must_equal [42]
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
            'id'   => nil,
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

        it 'sets the record as stored' do
          subject.wont_be :stored?
          subject.stored!
          subject.must_be :stored?
        end

        it 'sets the record as non-deleted' do
          subject.deleted!
          subject.must_be :deleted?
          subject.stored!
          subject.wont_be :deleted?
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
