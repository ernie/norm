class PersonRepo
  extend Norm::Repository

  self.table_name = 'people'
end

class Person
  extend Norm::Record

  self.repo = PersonRepo.new

  attribute :id, Attr::Integer
  attribute :name, Attr::String
  attribute :age, Attr::Integer
  attribute :created_at, Attr::Timestamp
  attribute :updated_at, Attr::Timestamp
end

person = Person.new :name => 'Bob', :age => 32
person.repo.insert person
