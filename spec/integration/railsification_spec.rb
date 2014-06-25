require 'spec_helper'

class Person < Norm::Record
  attribute :id,   Attr::Integer
  attribute :name, Attr::String
  attribute :age,  Attr::Integer
  identity  :id, :name, :age
end

describe_integration 'railsification' do
  I18n.enforce_available_locales = false
  I18n.locale = :en

  let(:railsified_delegator_class) {
    Class.new {
      include Norm::Record::Delegator(Person, railsify: true)
    }
  }
  subject { railsified_delegator_class }

  it 'extends ActiveModel::Naming' do
    subject.must_be_kind_of ActiveModel::Naming
  end

  it 'extends ActiveModel::Translation' do
    subject.must_be_kind_of ActiveModel::Translation
  end

  it 'includes ActiveModel::Validations' do
    subject.new.must_be_kind_of ActiveModel::Validations
  end

  it 'includes ActiveModel::Conversion' do
    subject.new.must_be_kind_of ActiveModel::Conversion
  end

  it 'includes ActiveModel::Serializers::JSON' do
    subject.new.must_be_kind_of ActiveModel::Serializers::JSON
  end

  it 'includes ActiveModel::Serializers::Xml' do
    subject.new.must_be_kind_of ActiveModel::Serializers::Xml
  end

  describe '.model_name' do

    it 'uses the Record class, not the Delegator, for naming' do
      subject.model_name.must_be_kind_of ActiveModel::Name
      subject.model_name.to_s.must_equal 'Person'
    end

  end

  describe '#persisted?' do

    it 'reflects the stored status of the Record' do
      person = subject.new
      person.wont_be :persisted?
      person.stored!
      person.must_be :persisted?
    end

  end

  describe '#new_record?' do

    it 'reflects the unstored status of the Record' do
      person = subject.new
      person.must_be :new_record?
      person.stored!
      person.wont_be :new_record?
    end

  end

  describe '#to_key' do

    it 'returns an array of identifying values for the record' do
      person = subject.new(:id => 1, :name => 'Ernie', :age => 36)
      person.to_key.must_equal [1, 'Ernie', 36]
    end

  end

  describe '#attributes' do

    it 'returns a hash of attributes with stringified keys' do
      person = subject.new(:id => 1, :name => 'Ernie', :age => 36)
      person.attributes.must_equal(
        'id' => 1, 'name' => 'Ernie', 'age' => 36
      )
    end

  end

  describe '#constraint_delegate' do

    it 'adds errors to the object' do
      person = subject.new
      error = Struct.new(:type, :column_name, :constraint_name).
        new(:not_null, 'name', 'constraint_name')
      person.constraint_delegate.constraint_error(error)
      person.errors[:name].must_include "can't be blank"
    end

  end

end
