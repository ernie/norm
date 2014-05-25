require 'spec_helper'

module Norm
  describe Attributes do
    subject { Class.new(Attributes) }

    describe '.names' do

      it 'is initially empty' do
        subject.names.must_equal []
      end

    end

    describe '.attribute' do

      it 'requires a name and a loader' do
        proc { subject.attribute }.must_raise ArgumentError
        proc { subject.attribute :zomg }.must_raise ArgumentError
        subject.attribute(:zomg, 'loader')
      end

      it 'adds attribute to .names' do
        subject.attribute(:zomg, 'loader')
        subject.names.must_equal [:zomg]
      end

      it 'defines an attribute type' do
        subject.attribute(:zomg, Norm::Attribute::Integer)
        instance = subject.new(:zomg => '42')
        instance[:zomg].must_equal 42
      end

    end

    describe 'with defined attributes' do
      subject {
        Class.new(Attributes) {
          attribute :id,   Attr::Integer
          attribute :name, Attr::String
        }
      }

      describe '.identity' do

        it 'requires at least one attribute' do
          error = proc { subject.identity }.must_raise ArgumentError
          error.message.must_equal 'Identity requires at least one attribute'
        end

        it 'gives instances an identifiers method returning the attributes' do
          subject.identity :id, :name
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.identifiers.must_equal(:id => 1, :name => 'Ernie')
        end

      end

      describe 'initialization' do

        it 'sets attributes that are defined' do
          instance = subject.new(:id => '42', :name => 7)
          instance[:id].must_equal 42
          instance[:name].must_equal '7'
        end

        it 'skips setting attributes that are not defined' do
          instance = subject.new(:zomg => 'bbq')
          instance[:id].must_be_nil
          instance[:name].must_be_nil
        end

        it 'allows changes inside a block before init is complete' do
          instance = subject.new do |attrs|
            attrs[:name] = 'Ernie'
          end
          instance[:name].must_equal 'Ernie'
          instance.wont_be :updated?
        end

      end

      describe '#names' do

        it 'returns names of attributes defined on the class' do
          subject.new.names.must_equal [:id, :name]
        end

      end

      describe '#[]=' do

        it 'sets the value of the attribute' do
          instance = subject.new
          instance[:name] = 'zomg'
          instance[:name].must_equal 'zomg'
        end

        it 'flags the attribute as updated' do
          instance = subject.new(:name => 'Ernie')
          instance[:name] = 'Bert'
          instance.updated.must_equal(:name => 'Bert')
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance[:zomg] = 123 }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

        it 'does not changed updated if no such attribute' do
          instance = subject.new
          proc { instance[:zomg] = 123 }.
            must_raise Attributes::NonexistentAttributeError
          instance.wont_be :updated?
        end

      end

      describe '#[]' do

        it 'gets the value of the attributes' do
          instance = subject.new(:name => 'zomg')
          instance[:name].must_equal 'zomg'
        end

        it 'returns Attribute::DEFAULT if attribute unset and default:true' do
          instance = subject.new(:name => 'zomg')
          instance[:id, default: true].must_equal(
            Attribute::DEFAULT
          )
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance[:zomg] }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

      end

      describe '#orig' do

        it 'gets the original value of the attributes' do
          instance = subject.new(:name => 'zomg')
          instance[:name] = 'bbq'
          instance.orig(:name).must_equal 'zomg'
        end

        it 'returns DEFAULT if attribute originally unset and default:true' do
          instance = subject.new(:name => 'zomg')
          instance[:id] = 1
          instance.orig(:id, default: true).must_equal(
            Attribute::DEFAULT
          )
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance.orig(:zomg) }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

      end

      describe '#all' do

        it 'returns all attributes in a hash' do
          instance = subject.new(:name => 'Ernie')
          instance.all.must_equal(:id => nil, :name => 'Ernie')
        end

        it 'returns Attribute::DEFAULT if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.all(default: true).
            must_equal(:id => Attribute::DEFAULT, :name => 'Ernie')
        end

      end

      describe '#initialized?' do

        it 'reflects whether the attributes object is finished initializing' do
          instance = subject.new { |attrs|
            attrs.wont_be :initialized?
          }
          instance.must_be :initialized?
        end

      end

      describe '#initialized' do

        it 'returns a hash of set attribute names and their values' do
          instance = subject.new(:name => 'Ernie')
          instance.initialized.must_equal(:name => 'Ernie')
        end

        it 'returns DEFAULT values if default: true' do
          instance = subject.new(:id => Attribute::DEFAULT, :name => 'Ernie')
          instance.initialized(default: true).
            must_equal(:id => Attribute::DEFAULT, :name => 'Ernie')
        end

        it 'returns nil for DEFAULT values if default: false' do
          instance = subject.new(:id => Attribute::DEFAULT, :name => 'Ernie')
          instance.initialized(default: false).
            must_equal(:id => nil, :name => 'Ernie')
        end

      end

      describe '#updated?' do

        it 'reflects whether the attributes have been changed since init' do
          instance = subject.new(:name => 'Ernie')
          instance.wont_be :updated?
          instance[:name] = 'Bert'
          instance.must_be :updated?
        end

      end

      describe '#updated' do

        it 'returns a hash of updated attribute names and their values' do
          instance = subject.new(:name => 'Ernie')
          instance[:id] = 1
          instance.updated.must_equal(:id => 1)
        end

        it 'returns DEFAULT values if default: true' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance[:id] = Attribute::DEFAULT
          instance.updated(default: true).must_equal(:id => Attribute::DEFAULT)
        end

        it 'returns nil for DEFAULT values if default: false' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance[:id] = Attribute::DEFAULT
          instance.updated(default: false).must_equal(:id => nil)
        end

      end

      describe '#identity?' do

        it 'is false when no identity was set on the class' do
          subject.new.wont_be :identity?
        end

        it 'is false when an identity was set but attr is nil' do
          subject.identity :id, :name
          subject.new(:id => nil, :name => 'Ernie').wont_be :identity?
        end

        it 'is false when an identity was set but attr is DEFAULT' do
          subject.identity :id, :name
          subject.new(:id => Attr::DEFAULT, :name => 'Ernie').wont_be :identity?
        end

        it 'is true if all identifying attributes are non-nil' do
          subject.identity :id, :name
          subject.new(:id => 1, :name => 'Ernie').must_be :identity?
        end

      end

      describe '#identifiers' do

        it 'returns a hash of the identifying attributes and their values' do
          subject.identity :id
          subject.new.identifiers.must_equal(:id => nil)
        end

        it 'returns a value of Attribute::DEFAULT if default: true' do
          subject.identity :id
          subject.new.identifiers(default: true).must_equal(
            :id => Attribute::DEFAULT
          )
        end

      end

      describe '#get_attributes' do

        it 'gets multiple attributes by name' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.get_attributes(:id, :name).
            must_equal(:id => 1, :name => 'Ernie')
        end

        it 'uses same key type as supplied args' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.get_attributes('id', :name).
            must_equal('id' => 1, :name => 'Ernie')
        end

        it 'returns DEFAULT for missing attributes if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.get_attributes(:id, :name, default: true).must_equal(
            :id => Attribute::DEFAULT, :name => 'Ernie'
          )
        end

        it 'returns nil for DEFAULT attributes if default: false' do
          instance = subject.new(:name => 'Ernie', :id => Attribute::DEFAULT)
          instance.get_attributes(:id, :name, default: false).must_equal(
            :id => nil, :name => 'Ernie'
          )
        end

      end

      describe '#set_attributes' do

        it 'sets values for existing attributes' do
          instance = subject.new
          instance.set_attributes(:id => 1, :name => 'Ernie')
          instance[:id].must_equal 1
          instance[:name].must_equal 'Ernie'
        end

        it 'skips setting values on nonexistent attributes' do
          instance = subject.new
          instance.set_attributes(:foo => 1, :name => 'Ernie')
          instance[:name].must_equal 'Ernie'
          proc { instance[:foo] }.must_raise(
            Attributes::NonexistentAttributeError
          )
        end

      end

      describe '#get_originals' do

        it 'returns values of attributes as originally set' do
          instance = subject.new(:name => 'Ernie')
          instance[:id]   = 1
          instance[:name] = 'Bert'
          instance.get_originals(:id, :name).must_equal(
            :id => nil, :name => 'Ernie'
          )
        end

        it 'returns DEFAULT for missing originals if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance[:id]   = 1
          instance[:name] = 'Bert'
          instance.get_originals(:id, :name, default: true).must_equal(
            :id => Attribute::DEFAULT, :name => 'Ernie'
          )
        end

      end

      describe '#values_at' do

        it 'returns an array of values requested' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.values_at(:id, :name).must_equal([1, 'Ernie'])
        end

        it 'returns the values in the same order requested' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.values_at(:name, :id).must_equal(['Ernie', 1])
        end

        it 'returns DEFAULT for unset attributes when default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.values_at(:id, :name, default: true).must_equal(
            [Attribute::DEFAULT, 'Ernie']
          )
        end

      end

      describe '#has_key?' do

        it 'returns true for attributes that exist on the class' do
          subject.new.must_be :has_key?, :id
        end

        it 'returns false for attributes that do not exist on the class' do
          subject.new.wont_be :has_key?, :foo
        end

      end

      describe '#commit!' do

        it 'resets the Attributes updated status' do
          instance = subject.new
          instance[:name] = 'Ernie'
          instance.must_be :updated?
          instance.commit!
          instance.wont_be :updated?
        end

      end

      describe '#reset!' do

        it 'sets the Attributes to original values' do
          instance = subject.new(:name => 'Ernie')
          instance[:id]   = 1
          instance[:name] = 'Bert'
          instance.reset!
          instance.wont_be :updated?
          instance[:name].must_equal 'Ernie'
          instance[:id, default: true].must_equal Attribute::DEFAULT
        end

      end

      describe '#inspect' do

        it 'prints a readable description of the Attributes object' do
          instance = subject.new(:name => 'Ernie')
          instance.inspect.must_match(
            /\A#<#<Class:.*?> id: <DEFAULT>, name: "Ernie">\z/
          )
        end

      end

      describe 'comparison' do
        let(:attributes1) {
          Class.new(Attributes) {
            attribute :id,   Attr::Integer
            attribute :name, Attr::String
            identity  :id
          }
        }

        let (:attributes1_subclass) {
          Class.new(attributes1)
        }

        let(:attributes2) {
          Class.new(Attributes) {
            attribute :id,   Attr::Integer
            attribute :name, Attr::String
            identity  :id
          }
        }

        subject { attributes1 }

        describe '#==' do

          it 'is true for attributes with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 1, :name => 'Bert')
            attr1.must_equal attr2
          end

          it 'is false for attributes with different identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 2, :name => 'Ernie')
            attr1.wont_equal attr2
          end

          it 'is false if attributes are missing identity' do
            attr1 = subject.new(:name => 'Ernie')
            attr2 = subject.new(:name => 'Ernie')
            attr1.wont_equal attr2
          end

          it 'is true for ancestor == child with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr1.must_equal attr2
          end

          it 'is true for child == ancestor with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr2.must_equal attr1
          end

          it 'is false for identical classes when not subclasses' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes2.new(:id => 1, :name => 'Ernie')
            attr1.wont_equal attr2
          end

        end

        describe '#eql?' do

          it 'is true for attributes with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 1, :name => 'Bert')
            attr1.must_be :eql?, attr2
          end

          it 'is false for attributes with different identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 2, :name => 'Ernie')
            attr1.wont_be :eql?, attr2
          end

          it 'is false if attributes are missing identity' do
            attr1 = subject.new(:name => 'Ernie')
            attr2 = subject.new(:name => 'Ernie')
            attr1.wont_be :eql?, attr2
          end

          it 'is false for ancestor == child with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr1.wont_be :eql?, attr2
          end

          it 'is false for child == ancestor with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr2.wont_be :eql?, attr1
          end

          it 'is false for identical classes when not subclasses' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes2.new(:id => 1, :name => 'Ernie')
            attr1.wont_be :eql?, attr2
          end

        end

        describe '#hash' do

          it 'implies eql? for attributes with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 1, :name => 'Bert')
            attr1.hash.must_equal attr2.hash
          end

          it 'implies !eql? for attributes with different identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 2, :name => 'Ernie')
            attr1.hash.wont_equal attr2.hash
          end

          it 'implies !eql? if attributes are missing identity' do
            attr1 = subject.new(:name => 'Ernie')
            attr2 = subject.new(:name => 'Ernie')
            attr1.hash.wont_equal attr2.hash
          end

          it 'implies !eql? for ancestor == child with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr1.hash.wont_equal attr2.hash
          end

          it 'implies !eql? for child == ancestor with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            attr2.hash.wont_equal attr1.hash
          end

          it 'implies !eql? for identically classes when not subclasses' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes2.new(:id => 1, :name => 'Ernie')
            attr1.hash.wont_equal attr2.hash
          end

        end

        describe '#<=>' do

          it 'is 0 for attributes with matching identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 1, :name => 'Bert')
            (attr1 <=> attr2).must_equal 0
          end

          it 'is -1 for attr1 identifiers < attr2 identifiers' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = subject.new(:id => 2, :name => 'Ernie')
            (attr1 <=> attr2).must_equal -1
          end

          it 'is 1 for attr1 identifiers > attr2 identifiers' do
            attr1 = subject.new(:id => 2, :name => 'Ernie')
            attr2 = subject.new(:id => 1, :name => 'Ernie')
            (attr1 <=> attr2).must_equal 1
          end

          it 'is nil if attributes are missing identity' do
            attr1 = subject.new(:name => 'Ernie')
            attr2 = subject.new(:name => 'Ernie')
            (attr1 <=> attr2).must_be_nil
          end

          it 'is nil for ancestor <=> child comparison' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            (attr1 <=> attr2).must_be_nil
          end

          it 'is nil for child <=> ancestor comparison' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes1_subclass.new(:id => 1, :name => 'Ernie')
            (attr2 <=> attr1).must_be_nil
          end

          it 'is nil for identical classes when not subclasses' do
            attr1 = subject.new(:id => 1, :name => 'Ernie')
            attr2 = attributes2.new(:id => 1, :name => 'Ernie')
            (attr1 <=> attr2).must_be_nil
          end

          it 'sorts when all objects are comparable' do
            attr1 = subject.new(:id => 2, :name => 'Bert')
            attr2 = subject.new(:id => 1, :name => 'Ernie')
            [attr1, attr2].sort.must_equal [attr2, attr1]
          end

          it 'raises ArgumentError on sort when an object is not comparable' do
            attr1 = subject.new(:id => 2, :name => 'Bert')
            attr2 = attributes2.new(:id => 1, :name => 'Ernie')
            proc { [attr1, attr2].sort }.must_raise ArgumentError
          end

        end

      end

    end

  end
end
