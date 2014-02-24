class Person
  extend Norm::Record

  attribute :id, Attr::Integer
  attribute :name, Attr::String
  attribute :age, Attr::Integer
  attribute :created_at, Attr::Timestamp
  attribute :updated_at, Attr::Timestamp
end