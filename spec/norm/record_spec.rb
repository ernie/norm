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

      it 'allows changes to the record via block' do
        record = subject.new do |r|
          r.name = 'Ernie'
        end
        record.name.must_equal 'Ernie'
        record.updated_attributes.must_be :empty?
      end

    end

    describe 'instance methods' do
      subject { simple_record_class.new }

      describe '#inspect' do

        it 'returns a legible string listing object attributes' do
          subject.name, subject.age = 'Ernie', 36
          subject.inspect.must_match(
            /\A#<#<Class:.*?> #<#<Class:.*?> id: <DEFAULT>, name: "Ernie", age: 36>>\z/
          )
        end

      end

      describe '#attribute_names' do

        it 'delegates to its attribute class by default' do
          simple_record_class.send(:attributes_class).stub(:names, ['zomg']) do
            subject.attribute_names.must_equal ['zomg']
          end
        end

      end

      describe '#identifying_attributes' do

        it 'returns a hash of identifying attribute keys and values' do
          subject.id = 42
          subject.identifying_attributes.must_equal('id' => 42)
        end

      end

      describe '#values_at' do

        it 'returns an array of values in the specified order' do
          record = simple_record_class.new(:name => 'Ernie', :age => 36)
          record.values_at(:age, :name).must_equal [36, 'Ernie']
        end

      end

      describe '#attributes' do

        it 'returns an attributes object' do
          record = simple_record_class.new(:id => 1, :name => 'Ernie Miller')
          record.attributes.must_equal(
            simple_record_class::Attributes.new(
              :id => 1,
              :name => 'Ernie Miller'
            )
          )
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

      describe '#get' do

        it 'uses the attribute readers to retrieve named attributes' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.get(:name, :id).must_equal(:name => 'Ernie Miller', :id => nil)
        end

      end

      describe '#set' do

        it 'uses the attribute writers to set attributes' do
          record = simple_record_class.new
          def record.name=(val)
            super('zomg')
          end
          record.set(:name => 'Ernie Miller')
          record.name.must_equal 'zomg'
        end

        it 'skips attributes with no writer' do
          record = simple_record_class.new
          record.set(:name => 'Ernie', :favorite_color => 'blue')
          record.name.must_equal 'Ernie'
        end

      end

      describe '#all_attributes' do

        it 'returns a hash of all attribute names and values' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.all_attributes.must_equal(
            'id' => nil, 'name' => 'Ernie Miller', 'age' => nil
          )
        end

        it 'includes default values in hash if default: true' do
          record = simple_record_class.new(:name => 'Ernie Miller')
          record.all_attributes(default: true).must_equal(
            'id'   => Attribute::Default.instance,
            'name' => 'Ernie Miller',
            'age'  => Attribute::Default.instance
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

      describe '#updated_attributes?' do
        subject { simple_record_class.new(:name => 'Ernie Miller', :age => 36) }

        it 'returns false if no attributes have been updated' do
          subject.wont_be :updated_attributes?
        end

        it 'returns true if an attribute has been updated' do
          subject.name = 'Bert'
          subject.must_be :updated_attributes?
        end

      end

      describe '#get_attributes' do

        it 'returns a hash of requested attributes using symbols' do
          record = simple_record_class.new(:name => 'Ernie')
          record.get_attributes(:name, :age).must_equal(
            :name => 'Ernie', :age => nil
          )
        end

        it 'returns a hash of requested attributes using strings' do
          record = simple_record_class.new(:name => 'Ernie')
          record.get_attributes('name', 'age').must_equal(
            'name' => 'Ernie', 'age' => nil
          )
        end

        it 'does not filter list of requested attributes' do
          record = simple_record_class.new(:name => 'Ernie', :age => 36)
          proc { record.get_attributes(:name, :age, :favorite_color) }.
            must_raise Attributes::NonexistentAttributeError
        end

      end

      describe '#set_attributes' do

        it 'updates attributes common between the record and hash' do
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
          subject.updated_attributes.keys.must_include 'name'
          subject.inserted!
          subject.updated_attributes.must_be :empty?
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
          subject.updated_attributes.keys.must_include 'name'
          subject.updated!
          subject.updated_attributes.must_be :empty?
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
