module Norm
  class Repository
    class Scoped < Repository
      attr_reader :scoper

      def initialize(record_class, scoper, **args)
        super(record_class, **args)
        @scoper = scoper
      end

      def select_one(statement, *)
        statement = scoper.select_one(statement)
        super
      end

      def select_many(statement, *)
        statement = scoper.select_many(statement)
        super
      end

      def insert_one(statement, record, *)
        statement = scoper.insert_one(statement, record)
        super
      end

      def insert_many(statement, records, *)
        statement = scoper.insert_many(statement, record)
        super
      end

      def update_one(statement, record, *)
        statement = scoper.update_one(statement, record)
        super
      end

      def update_many(statement, records, *)
        statement = scoper.update_many(statement, records)
        super
      end

      def delete_one(statement, record, *)
        statement = scoper.delete_one(statement, record)
        super
      end

      def delete_many(statement, records, *)
        statement = scoper.delete_many(statement, records)
        super
      end

    end
  end
end
