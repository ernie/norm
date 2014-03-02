class Person
  extend Norm::Record
  self.table_name = 'people'

  attribute :id, Attr::Integer
  attribute :name, Attr::String
  attribute :age, Attr::Integer
  attribute :created_at, Attr::Timestamp
  attribute :updated_at, Attr::Timestamp
end
