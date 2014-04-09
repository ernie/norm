class Person < Norm::Record
  attribute :id, Attr::Integer
  attribute :name, Attr::String
  attribute :age, Attr::Integer
  attribute :created_at, Attr::Timestamp
  attribute :updated_at, Attr::Timestamp
end

class PersonRepo < Norm::MemoryRepository
  self.record_class = Person

  def default_age
    0
  end
end

person = Person.new :name => 'Bob', :age => 32
person.repo.insert person
