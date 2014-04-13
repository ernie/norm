require 'spec_helper'

module Norm
  module Attribute
    describe Loader do

      subject { Loader.new }
      let(:inherited) {
        Loader.new.tap { |loader|
          loader.set_loader(:id, Integer)
        }
      }

      describe '#set_loader' do

        it 'sets an object for loading an attribute by name' do
          subject.set_loader 'key', Integer
          subject.load(:key, '42').must_equal 42
        end

      end

      describe 'without inherited loader' do

        describe '#load' do

          it 'requires more than one parameter' do
            proc { subject.load }.must_raise ArgumentError
            proc { subject.load :id }.must_raise ArgumentError
          end

          it 'raises LoadingError on load of unknown key' do
            error = proc { subject.load(:id, nil) }.must_raise LoadingError
            error.message.must_equal 'No loader for "id" is defined'
          end

        end

      end

      describe 'with inherited loader' do
        subject { Loader.new(inherited) }

        it 'loads using inherited loader when nothing local is defined' do
          subject.load(:id, '42').must_equal 42
        end
      end

    end
  end
end
