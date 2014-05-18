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
        subject.names.must_equal ['zomg']
      end

      it 'defines an attribute type' do
        subject.attribute(:zomg, Norm::Attribute::Integer)
        instance = subject.new(:zomg => '42')
        instance.get(:zomg).must_equal 42
      end

    end

    describe 'with defined attributes' do
      subject {
        Class.new(Attributes) {
          attribute :id,   Attr::Integer
          attribute :name, Attr::String
        }
      }

      describe 'initialization' do

        it 'sets attributes that are defined' do
          instance = subject.new(:id => '42', :name => 7)
          instance.get(:id).must_equal 42
          instance.get(:name).must_equal '7'
        end

        it 'skips setting attributes that are not defined' do
          instance = subject.new(:zomg => 'bbq')
          instance.get(:id).must_be_nil
          instance.get(:name).must_be_nil
        end

      end

      describe '#names' do

        it 'returns names of attributes defined on the class' do
          subject.new.names.must_equal ['id', 'name']
        end

      end

      describe '#set' do

        it 'sets the value of the attribute' do
          instance = subject.new
          instance.set(:name, 'zomg')
          instance.get(:name).must_equal 'zomg'
        end

        it 'is aliased to []=' do
          instance = subject.new
          instance[:name] = 'zomg'
          instance.get(:name).must_equal 'zomg'
        end

        it 'flags the attribute as updated' do
          instance = subject.new(:name => 'Ernie')
          instance[:name] = 'Bert'
          instance.updated.must_equal('name' => 'Bert')
          instance.updates.must_equal('name' => ['Ernie', 'Bert'])
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance.set(:zomg, 123) }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

        it 'does not change updated hash if no such attribute' do
          instance = subject.new
          proc { instance.set(:zomg, 123) }.
            must_raise Attributes::NonexistentAttributeError
          instance.updates.must_be :empty?
        end

      end

      describe '#get' do

        it 'gets the value of the attribute' do
          instance = subject.new(:name => 'zomg')
          instance.get(:name).must_equal 'zomg'
        end

        it 'returns Attribute::Default if attribute unset and default:true' do
          instance = subject.new(:name => 'zomg')
          instance.get(:id, default: true).must_equal(
            Attribute::Default.instance
          )
        end

        it 'is aliased to []' do
          instance = subject.new(:name => 'zomg')
          instance[:name].must_equal 'zomg'
        end

        it 'raises NonexistentAttributeError if no such attribute' do
          instance = subject.new
          error = proc { instance.get(:zomg) }.
            must_raise Attributes::NonexistentAttributeError
          error.message.must_equal 'No such attribute: zomg'
        end

      end

      describe '#all' do

        it 'returns all attributes in a hash' do
          instance = subject.new(:name => 'Ernie')
          instance.all.must_equal('id' => nil, 'name' => 'Ernie')
        end

        it 'returns Attribute::Default if default: true' do
          instance = subject.new(:name => 'Ernie')
          instance.all(default: true).
            must_equal('id' => Attribute::Default.instance, 'name' => 'Ernie')
        end

      end

      describe '#initialized' do

        it 'returns any attributes which have been set' do
          instance = subject.new(:name => 'Ernie')
          instance.initialized.must_equal('name' => 'Ernie')
        end

      end

    end

  end
end
