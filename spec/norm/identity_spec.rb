require 'spec_helper'

module Norm
  describe Identity do

    subject {
      Class.new {
        extend Identity
        identity :id

        attr_accessor :id, :name, :age
      }
    }
    let(:object1) { subject.new }
    let(:object2) { subject.new }
    let(:subclass) { Class.new(subject) }
    let(:subclassed_object) { subclass.new }

    describe '.identity' do

      it 'requires at least one attribute name' do
        proc { subject.identity }.must_raise ArgumentError
      end

      it 'adds ==, eql?, hash, and identity? instance methods' do
        klass = Class.new { extend Identity }
        (klass.instance_methods(false) & [:==, :eql?, :hash, :identity?]).
          must_be :empty?
        klass.identity :id
        (klass.instance_methods(false) & [:==, :eql?, :hash, :identity?]).
          size.must_equal 4
      end

    end

    describe '#identity?' do

      it 'is true if no identifying attributes are nil' do
        object = subject.new
        object.id = 1
        object.identity?.must_equal true
      end

      it 'is false if any identifying attribute is nil' do
        subject.identity :id, :name
        object = subject.new
        object.id = 1
        object.identity?.must_equal false
      end

    end

    describe 'equivalence' do

      it 'requires both objects to have identities' do
        object1.wont_equal object2
        object1.id = 1
        object1.wont_equal object2
        object2.id = 1
        object1.must_equal object2
      end

      it 'is true for otherwise-equivalent subclasses' do
        object1.id = 1
        subclassed_object.id = 1
        object1.must_equal subclassed_object
      end

      it 'is symmetric' do
        object1.id = 1
        subclassed_object.id = 1
        object1.must_equal subclassed_object
        subclassed_object.must_equal object1
      end

    end

    describe 'hash equality' do

      it 'requires both objects to have identities' do
        object1.wont_be :eql?, object2
        object1.id = 1
        object1.wont_be :eql?, object2
        object2.id = 1
        object1.must_be :eql?, object2
      end

      it 'is false for otherwise-equivalent subclasses' do
        object1.id = 1
        subclassed_object.id = 1
        object1.wont_be :eql?, subclassed_object
      end

      it 'is symmetric' do
        object1.id = 1
        object2.id = 1
        object1.must_be :eql?, object2
        object2.must_be :eql?, object1
      end

      it 'uniquely identifies an object' do
        object1.id = 1
        object2.id = 1
        [object1, object2].uniq.size.must_equal 1
      end

    end

  end
end
