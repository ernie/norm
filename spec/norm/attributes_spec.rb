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
          instance.updates.must_be :empty?
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
          instance.updates.must_equal(:name => ['Ernie', 'Bert'])
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance[:zomg] = 123 }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

        it 'does not change updated hash if no such attribute' do
          instance = subject.new
          proc { instance[:zomg] = 123 }.
            must_raise Attributes::NonexistentAttributeError
          instance.updates.must_be :empty?
        end

      end

      describe '#[]' do

        it 'gets the value of the attributes' do
          instance = subject.new(:name => 'zomg')
          instance[:name].must_equal 'zomg'
        end

        it 'returns Attribute::Default if attribute unset and default:true' do
          instance = subject.new(:name => 'zomg')
          instance[:id, default: true].must_equal(
            Attribute::Default.instance
          )
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance[:zomg] }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

      end

      describe '#all' do

        it 'returns all attributes in a hash' do
          instance = subject.new(:name => 'Ernie')
          instance.all.must_equal(:id => nil, :name => 'Ernie')
        end

        it 'returns Attribute::Default if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.all(default: true).
            must_equal(:id => Attribute::Default.instance, :name => 'Ernie')
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

      end

      describe '#updates' do

        it 'returns a hash of the updated attributes with before and after' do
          instance = subject.new(:name => 'Ernie')
          instance[:id] = 1
          instance.updates.must_equal(:id => [Attribute::Default.instance, 1])
        end

      end

      describe '#identity?' do

        it 'is false when no identity was set on the class' do
          subject.new.wont_be :identity?
        end

        it 'is false when an identity was set on the class but attr is nil' do
          subject.identity :id, :name
          subject.new(:id => nil, :name => 'Ernie').wont_be :identity?
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

        it 'returns a value of Default if default: true' do
          subject.identity :id
          subject.new.identifiers(default: true).must_equal(
            :id => Attribute::Default.instance
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

        it 'returns Default for missing attributes if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.get_attributes(:id, :name, default: true).must_equal(
            :id => Attribute::Default.instance, :name => 'Ernie'
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

      describe '#values_at' do

        it 'returns an array of values requested' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.values_at(:id, :name).must_equal([1, 'Ernie'])
        end

        it 'returns the values in the same order requested' do
          instance = subject.new(:id => 1, :name => 'Ernie')
          instance.values_at(:name, :id).must_equal(['Ernie', 1])
        end

        it 'returns Default for unset attributes when default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.values_at(:id, :name, default: true).must_equal(
            [Attribute::Default.instance, 'Ernie']
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

      describe '#clear_updates!' do

        it 'resets the Attributes updated status' do
          instance = subject.new
          instance[:name] = 'Ernie'
          instance.must_be :updated?
          instance.clear_updates!
          instance.wont_be :updated?
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

    end

  end
end
