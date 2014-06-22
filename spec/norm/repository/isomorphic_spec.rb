require 'spec_helper'

module Norm
  class Repository
    describe Isomorphic do
      let(:person_record_class) {
        Class.new(Record) do
          attribute :id,         Attr::Integer
          attribute :name,       Attr::String
          attribute :age,        Attr::Integer
          attribute :created_at, Attr::Timestamp
          attribute :updated_at, Attr::Timestamp
        end
      }
      let(:person_repo) {
        Class.new(Repository::Isomorphic) {
          def table_name
            :people
          end
        }.new(person_record_class)
      }

      subject { person_repo }

      it 'requires subclasses implement table_name' do
        proc {
          Class.new(Repository::Isomorphic).new(person_record_class).table_name
        }.must_raise NotImplementedError
      end

      describe '#select_statement' do

        it 'is derived from table name' do
          subject.select_statement.sql.must_equal "SELECT *\nFROM \"people\""
        end

      end

      describe '#insert_statement' do

        it 'is derived from table name' do
          subject.insert_statement.sql.must_equal(
            "INSERT INTO \"people\" (\"id\", \"name\", \"age\", \"created_at\", \"updated_at\")\nRETURNING *"
          )
        end

      end

      describe '#update_statement' do

        it 'is derived from table name' do
          subject.update_statement.sql.must_equal(
            "UPDATE \"people\"\nRETURNING *"
          )
        end

      end

      describe '#delete_statement' do

        it 'is derived from table name' do
          subject.delete_statement.sql.must_equal(
            "DELETE FROM \"people\"\nRETURNING *"
          )
        end

      end

    end
  end
end
