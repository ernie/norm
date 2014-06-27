require 'spec_helper'

module Norm
  class Repository
    describe Scoped do

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
        Class.new(Repository) {
          def select_statement
            Norm::SQL.select.from('people')
          end

          def insert_statement
            Norm::SQL.insert(:people, attribute_names).returning('*')
          end

          def update_statement
            Norm::SQL.update('people').returning('*')
          end

          def delete_statement
            Norm::SQL.delete('people').returning('*')
          end
        }.new(person_record_class)
      }

      let(:person) {
        person = person_record_class.new(:name => 'Ernie', :age => 36)
        person_repo.insert(person)
        person
      }

      let(:scoper_class) {
        Class.new {
          def initialize(record)
            @record = record
          end

          def select_one(statement)
            statement.where(:person_id => @record.id)
          end

          def select_many(statement)
            statement.where(:person_id => @record.id)
          end

          def insert_one(statement, record)
            record.person_id = @record.id
            statement
          end
        }.new(person)
      }

      let(:post_record_class) {
        Class.new(Record) do
          attribute :id,         Attr::Integer
          attribute :person_id,  Attr::Integer
          attribute :title,      Attr::String
          attribute :body,       Attr::String
          attribute :created_at, Attr::Timestamp
          attribute :updated_at, Attr::Timestamp
        end
      }

      let(:post_repo_class) {
        Class.new(Scoped) {
          def select_statement
            Norm::SQL.select.from('posts')
          end

          def insert_statement
            Norm::SQL.insert(:posts, attribute_names).returning('*')
          end

          def update_statement
            Norm::SQL.update('posts').returning('*')
          end

          def delete_statement
            Norm::SQL.delete('posts').returning('*')
          end
        }
      }

      describe 'initialization' do
        subject { post_repo_class }

        it 'requires a record class and a scoper' do
          proc { subject.new(post_record_class) }.must_raise ArgumentError
          subject.new(post_record_class, :scoper).
            must_be_kind_of post_repo_class
        end

      end

      it 'provides a reader for its scoper' do
        repo = post_repo_class.new(post_record_class, :scoper)
        repo.scoper.must_equal :scoper
      end

      describe 'with a scoper on a person' do
        subject { post_repo_class.new(post_record_class, scoper) }
      end

    end
  end
end
